require "test_helper"

class StateTest < Minitest::Test
  include Rubio::State::Core

  test "states can be run" do
    f = ->(x) {
      ["Hello, #{x}!", x]
    }

    state = State[f]

    assert_equal ["Hello, world!", "world"], runState[state]["world"]
  end

  test "states can be bound together" do
    push1 = push[1]
    push2 = push[2]
    push3 = push[3]

    state = push1 >> push2 >> push3 >> pop

    assert_equal [3, [2, 1, 10, 11]], runState[state][ [10, 11] ]
  end

  test "states can be bound to callables" do

    state = push[1] >> push[2] >> push[3] >> pop >> ->(x) {
      push[x * x]
    } >> push[4] >> pop

    assert_equal [4, [9, 2, 1, 10, 11]], runState[state][ [10, 11] ]
  end

  test "extremely large numbers of States can be bound together" do
    incrementState = State[ ->(s) { [nil, s + 1] } ]
    increment      = ->(n) { n + 1 }

    size = 20000

    id = State[ ->(s) { [nil, s] } ]

    longState = size.times.inject(id) { |z, _| 
      z >> incrementState
    }

    control = size.times.inject(1) { |z, _|
      increment[z]
    }

    assert_equal control, runState[longState][1].last
  end

  test "inspecting State yields a meaningful value" do
    assert_equal "State", pop.inspect
  end

  private

  def push
    ->(x) {
      State[
        ->(xs) { [nil, [x] + xs] }
      ]
    }
  end

  def pop
    State[
      ->(xs) { [ xs.first, xs.drop(1) ] }
    ]
  end
end
