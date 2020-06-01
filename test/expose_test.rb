require "test_helper"

module DummyModule
  extend Rubio::Expose

  private_variable = 6

  public_variable = private_variable * 7
  
  expose :public_variable, public_variable
end

class ExposeTest < Minitest::Test
  extend DummyModule

  included_variable = public_variable

  test "expose creates an includeable method" do
    assert_equal included_variable, 42, "included_variable is accessible"
  end 
end
