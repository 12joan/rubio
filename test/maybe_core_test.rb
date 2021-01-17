require "test_helper"

class MaybeCoreTest < Minitest::Test
  include Rubio::Maybe::Core

  test "pure :: a -> Maybe a" do
    maybe = pureMaybe[42]

    assert_equal 42, maybe.get!
  end

  test "Just[x] = Just x" do
    maybe = Just[42]

    assert_equal 42, maybe.get!
  end

  test "Nothing = Nothing" do
    assert_instance_of Rubio::Maybe::NothingClass, Nothing
  end

  test "pattern matching on Just" do
    maybe = Just[42]

    result =
      case maybe
      in Just[x]
        "It is #{x}"
      in Nothing
        "There is nothing"
      end

    assert_equal "It is 42", result
  end

  test "pattern matching on Nothing" do
    maybe = Nothing

    result =
      case maybe
      in Just[x]
        "It is #{x}"
      in Nothing
        "There is nothing"
      end

    assert_equal "There is nothing", result
  end
end
