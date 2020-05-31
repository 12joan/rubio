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

  test "hClose :: Handle -> IO ()" do
    handle = open("test/test_data/file1", "r")

    hClose[handle].perform!

    assert_predicate handle, :closed?
  end

  test "readFile :: Handle -> IO String" do
    handle = open("test/test_data/file1", "r")

    assert_match( /Hello world!/, readFile[handle].perform! )
  end

  test "withFile :: FilePath -> IOMode -> (Handle -> IO a) -> IO a" do
    io = withFile["test/test_data/file1"]["r"][readFile]

    assert_match( /Hello world!/, io.perform! )
  end
end
