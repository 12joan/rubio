require_relative "support"

# WARNING: Pattern matching is an experimental feature of Ruby 2.7

include Rubio::Maybe::Core
include Rubio::IO::Core

doSomethingWithMaybe = ->(maybe) {
  case maybe
  in Just[x]
    "You got #{x}!"
  in Nothing
    "You got nothing."
  end
}

parseToMaybe = ->(string) {
  case string.strip
  in ""
    Nothing
  in x
    Just[x]
  end
}

main = println["Say something."] >> getln >> (println << doSomethingWithMaybe << parseToMaybe)

main.perform!
