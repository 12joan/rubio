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
end
