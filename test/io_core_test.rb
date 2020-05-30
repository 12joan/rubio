require "test_helper"

class IOCoreTest < Minitest::Test
  include Rubio::IO::Core

  test "pure :: a -> IO a" do
    io = pureIO[42]

    assert_equal 42, io.perform!
  end

  test "openFile :: FilePath -> IOMode -> IO Handle" do
    io_handle = openFile["test/test_data/file1"]["r"]

    handle = io_handle.perform!
    assert_match( /Hello world!/, handle.read )

    handle.close
  end

  test "hClose :: Handle -> IO" do
    handle = open("test/test_data/file1", "r")

    hClose[handle].perform!

    assert_predicate handle, :closed?
  end
end
