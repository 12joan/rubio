require "test_helper"

class EitherTest < Minitest::Test
  test "get (Right x) = x" do
    either = Rubio::Either::RightClass.new(42)
    assert_equal 42, either.get!
  end

  test "get (Left x) = x" do
    either = Rubio::Either::LeftClass.new(24)
    assert_equal 24, either.get!
  end

  test "get_or_else (Right x) _ = x" do
    either = Rubio::Either::RightClass.new(42)
    assert_equal 42, either.get_or_else(6)
  end

  test "get_or_else (Left _) x = x" do
    either = Rubio::Either::LeftClass.new(42)
    assert_equal 6, either.get_or_else(6)
  end

  test "(Right x) >> f = f x" do
    either1 = Rubio::Either::RightClass.new(42)
    f = ->(x) { Rubio::Either::RightClass.new(x / 6) }
    either2 = either1 >> f

    assert_equal 7, either2.get!
  end

  test "(Left x) >> f = (Left x)" do
    either1 = Rubio::Either::LeftClass.new(42)
    f = ->(x) { Rubio::Either::RightClass.new(x / 6) }
    either2 = either1 >> f

    assert_equal 42, either2.get!
  end

  test "fmap f (Right x) = Right (f x)" do
    either1 = Rubio::Either::RightClass.new("hello")
    f = ->(x) { x.upcase }
    either2 = either1.fmap(f)

    assert_equal "HELLO", either2.get!
  end

  test "fmap f (Left x) = (Left x)" do
    either1 = Rubio::Either::LeftClass.new("hello")
    f = ->(x) { x.upcase }
    either2 = either1.fmap(f)

    assert_equal "hello", either2.get!
  end

  test "inspecting (Right x) yields a meaningful value" do
    either = Rubio::Either::RightClass.new(5)
    assert_equal "Right 5", either.inspect
  end

  test "inspecting (Left x) yields a meaningful value" do
    either = Rubio::Either::LeftClass.new(7)
    assert_equal "Left 7", either.inspect
  end

  test "(Right x) = (Right y) <==> x = y" do
    CustomEquality = Struct.new(:x) do
      def ==(other)
        (self.x % 2) == (other.x % 2)
      end
    end

    rightCustomEquality = ->(x) {
      Rubio::Either::RightClass.new(CustomEquality.new(x)) 
    }

    assert_equal rightCustomEquality[4], rightCustomEquality[6]
    refute_equal rightCustomEquality[4], rightCustomEquality[7]
  end

  test "(Right x) != (Left y)" do
    refute_equal Rubio::Either::RightClass.new(4), Rubio::Either::LeftClass.new(4)
  end

  test "(Left x) = (Left y) <==> x = y" do
    assert_equal Rubio::Either::LeftClass.new(4), Rubio::Either::LeftClass.new(4)
    refute_equal Rubio::Either::LeftClass.new(4), Rubio::Either::LeftClass.new(7)
  end
end
