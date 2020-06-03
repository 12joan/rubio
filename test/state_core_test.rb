require "test_helper"

class StateCoreTest < Minitest::Test
  include Rubio::State::Core
  include Rubio::Unit::Core
  include Rubio::IO::Core

  test "State :: (s -> (a, s)) -> State s a" do
    state = State[ ->(x) { [x, x] } ]
    assert_instance_of Rubio::State::StateClass, state
  end

  test "StateIO :: (s -> IO (a, s)) -> StateT s IO a" do
    state = StateIO[ ->(x) { pureIO[[x, x]] } ]
    assert_instance_of Rubio::State::StateClass, state
  end

  test "liftIO :: IO a -> StateT s IO a" do
    state = liftIO[ pureIO[5] ]

    assert_equal 5, evalStateT[state]["whatever"].perform!
  end

  test "pureState :: a -> State s a" do
    state = pureState[5]

    assert_equal [5, "Hello"], runState[state]["Hello"]
  end 

  test "pureStateIO :: a -> StateT s IO a" do
    state = pureStateIO[5]

    assert_equal [5, "whatever"], runStateT[state]["whatever"].perform!
  end 

  test "get :: State s s" do
    assert_equal [5, 5], runState[get][5]
  end

  test "getIO :: StateT s IO s" do
    assert_equal [5, 5], runStateT[getIO][5].perform!
  end

  test "put :: s -> State s ()" do
    state = put["5"]
    
    assert_equal [unit, "5"], runState[state]["anything"]
  end

  test "putIO :: s -> StateT s IO ()" do
    state = putIO["5"]
    
    assert_equal [unit, "5"], runStateT[state]["anything"].perform!
  end

  test "modify :: (s -> s) -> State s ()" do
    double = ->(x) { x * 2 }

    state = modify[double]

    assert_equal [unit, 42], runState[state][21]
  end

  test "modifyIO :: (s -> s) -> State s IO ()" do
    double = ->(x) { x * 2 }

    state = modifyIO[double]

    assert_equal [unit, 42], runStateT[state][21].perform!
  end

  test "gets :: (s -> a) -> State s a" do
    double = ->(x) { x * 2 }

    state = put[5] >> gets[double]

    assert_equal [10, 5], runState[state][7]
  end

  test "getsIO :: (s -> a) -> State s a" do
    double = ->(x) { x * 2 }

    state = putIO[5] >> getsIO[double]

    assert_equal [10, 5], runStateT[state][7].perform!
  end

  test "runState -> State s a -> s -> (a, s)" do
    state = push[1] >> push[2] >> push[3] >> pop

    assert_equal [3, [2, 1, 10, 11]], runState[state][ [10, 11] ]
  end

  test "runStateIO -> State s IO a -> s -> IO (a, s)" do
    state = pushIO[1] >> pushIO[2] >> pushIO[3] >> popIO

    assert_equal [3, [2, 1, 10, 11]], runStateT[state][ [10, 11] ].perform!
  end

  test "evalState :: State s a -> s -> a" do
    state = push[1] >> push[2] >> push[3] >> pop

    assert_equal 3, evalState[state][ [10, 11] ]
  end

  test "evalStateIO :: State s IO a -> s -> IO a" do
    state = pushIO[1] >> pushIO[2] >> pushIO[3] >> popIO

    assert_equal 3, evalStateT[state][ [10, 11] ].perform!
  end

  test "execState :: State s a -> s -> s" do
    state = push[1] >> push[2] >> push[3] >> pop

    assert_equal [2, 1, 10, 11], execState[state][ [10, 11] ]
  end

  test "execStateT :: State s IO a -> s -> s" do
    state = pushIO[1] >> pushIO[2] >> pushIO[3] >> popIO

    assert_equal [2, 1, 10, 11], execStateT[state][ [10, 11] ].perform!
  end

  test "StateIO cumulatively binds lifted IOs" do
    state = popIO >> ->(x) {
      (liftIO << println)["I just popped #{x}"] >>
      popIO >> ->(y) {
        (liftIO << println)["I just popped #{y}"] >>
        pushIO[x] >>
        pushIO[y] >>
        getIO >> ->(s) {
          (liftIO << println)["The state is now #{s.inspect}"]
        }
      }
    }

    io = evalStateT[state][ [1, 2, 3, 4, 5] ]

    assert_output "I just popped 1\nI just popped 2\nThe state is now [2, 1, 3, 4, 5]\n" do
      io.perform!
    end
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

  def pushIO
    ->(x) {
      modifyIO[ ->(xs) {
        [x] + xs
      }]
    }
  end

  def popIO
    head = proc(&:first)
    tail = ->(xs) { xs.drop(1) }

    getsIO[head] >> ->(x) {
      modifyIO[tail] >> pureStateIO[x]
    }
  end
end
