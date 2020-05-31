require "test_helper"

class StateTest < Minitest::Test
  test "states can be run" do
    f = ->(x) {
      ["Hello, #{x}!", x]
    }

    state = Rubio::State.new(f)

    assert_equal f, state.run
  end

  # Used below
  push = ->(x) {
    Rubio::State.new(
      ->(xs) { [nil, [x] + xs] }
    )
  }

  pop = Rubio::State.new(
    ->(xs) { [ xs.first, xs.drop(1) ] }
  )

  test "states can be bound together" do
    push1 = push[1]
    push2 = push[2]
    push3 = push[3]

    state = push1 >> push2 >> push3 >> pop

    assert_equal [3, [2, 1, 10, 11]], state.run[ [10, 11] ]
  end

  test "states can be bound to callables" do

    state = push[1] >> push[2] >> push[3] >> pop >> ->(x) {
      push[x * x]
    } >> push[4] >> pop

    assert_equal [4, [9, 2, 1, 10, 11]], state.run[ [10, 11] ]
  end

  test "inspecting State yields a meaningful value" do
    assert_equal "State", pop.inspect
  end
end
