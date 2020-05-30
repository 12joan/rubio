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
end
