require "coveralls"
Coveralls.wear!

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "rubio"

require "minitest/autorun"

class Minitest::Test
  def self.test(test_name, &body)
    define_method( "test_" + test_name.gsub(" ", "_"), body )
  end
end
