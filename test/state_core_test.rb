require "test_helper"

class StateCoreTest < Minitest::Test
  include Rubio::State::Core
  include Rubio::Unit::Core

  test "State :: (s -> (a, s)) -> State s a" do
    state = State[ ->(x) { [x, x] } ]
    assert_instance_of Rubio::State::StateClass, state
  end

  test "pure :: a -> State s a" do
    state = pureState[5]

    assert_equal [5, "Hello"], runState[state]["Hello"]
  end 

  test "get :: State s s" do
    assert_equal [5, 5], runState[get][5]
  end

  test "put :: s -> State s ()" do
    state = put["5"]
    
    assert_equal [unit, "5"], runState[state]["anything"]
  end

  test "modify :: (s -> s) -> State s ()" do
    double = ->(x) { x * 2 }

    state = modify[double]

    assert_equal [unit, 42], runState[state][21]
  end

  test "gets :: (s -> a) -> State s a" do
    double = ->(x) { x * 2 }

    state = put[5] >> gets[double]

    assert_equal [10, 5], runState[state][7]
  end


  test "runState -> State s a -> s -> (a, s)" do
    state = push[1] >> push[2] >> push[3] >> pop

    assert_equal [3, [2, 1, 10, 11]], runState[state][ [10, 11] ]
  end

  test "evalState :: State s a -> s -> a" do
    state = push[1] >> push[2] >> push[3] >> pop
    assert_equal 3, evalState[state][ [10, 11] ]
  end

  test "execState :: State s a -> s -> s" do
    state = push[1] >> push[2] >> push[3] >> pop

    assert_equal [2, 1, 10, 11], execState[state][ [10, 11] ]
  end

  private

  def push
    ->(x) {
      modify[ ->(xs) {
        [x] + xs
      }]
    }
  end

  def pop
    head = proc(&:first)
    tail = ->(xs) { xs.drop(1) }

    gets[head] >> ->(x) {
      modify[tail] >> pureState[x]
    }
  end
end
