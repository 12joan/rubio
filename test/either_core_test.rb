require "test_helper"

class EitherCoreTest < Minitest::Test
  include Rubio::Either::Core

  test "pure :: a -> Either a" do
    either = pureEither[42]

    assert_instance_of Rubio::Either::RightClass, either
    assert_equal 42, either.get!
  end

  test "Right[x] = Right x" do
    either = Right[42]

    assert_instance_of Rubio::Either::RightClass, either
    assert_equal 42, either.get!
  end

  test "Left[x] = Left x" do
    either = Left[42]

    assert_instance_of Rubio::Either::LeftClass, either
    assert_equal 42, either.get!
  end
end
