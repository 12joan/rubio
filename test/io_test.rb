require "test_helper"

class IOTest < Minitest::Test
  test "IOs can be performed" do
    io = nil

    assert_silent {
      io = Rubio::IO.new { puts "side effect" }
    }

    assert_output(/side effect/) {
      io.perform!
    }
  end 

  test "IOs can be bound to other IOs" do
    io1 = Rubio::IO.new { printf "Hello " }
    io2 = Rubio::IO.new { printf "World" }

    io3 = io1 >> io2

    assert_output(/Hello World/) {
      io3.perform!
    }
  end

  test "IOs can be bound to callable objects" do
    io1 = Rubio::IO.new { 42 }

    f = ->(x) {
      Rubio::IO.new { puts x }
    }

    io2 = io1 >> f

    assert_output(/42/) {
      io2.perform!
    }
  end

  test "extremely large numbers of IOs can be bound together" do
    incrementIO = ->(n) { Rubio::IO.new { n + 1 } }
    increment   = ->(n) { n + 1 }

    size = 10000

    longIO = size.times.inject( Rubio::IO.new { 1 } ) { |z, _| 
      z >> incrementIO
    }

    control = size.times.inject(1) { |z, _|
      increment[z]
    }

    assert_equal control, longIO.perform!
  end

  test "fmap :: (a -> b) -> IO a -> IO b" do
    io1 = Rubio::IO.new { "Hello" }
    reverse = ->(x) { x.reverse }
    io2 = io1.fmap(reverse)

    assert_equal "olleH", io2.perform!
  end

  test "inspecting IO yields a meaningful value" do
    io = Rubio::IO.new { 5 }
    assert_equal "IO", io.inspect
  end
end
