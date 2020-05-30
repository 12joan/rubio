require "test_helper"

class IOCoreTest < Minitest::Test
  include Rubio::IO::Core

  test "pure :: a -> IO a" do
    io = pureIO[42]

    assert_equal 42, io.perform!
  end

  test "fmap :: (a -> b) -> IO a -> IO b" do
    reverse = ->(x) { x.reverse }
    io1 = pureIO["Hello"]
    io2 = fmap[reverse][io1]

    assert_equal "olleH", io2.perform!
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
