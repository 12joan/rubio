require_relative "support"
require_relative "whileM"

include Rubio::IO::Core
include WhileM

# evaluate :: String -> IO Bool
evaluate = ->(input) {
  stop     = pureIO[false]
  continue = pureIO[true]

  case input.chomp
  when "exit"
    stop
  when "help"
    println["Try typing 'exit'"] >> continue
  else
    println["Command not found. Try typing 'help'"] >> continue
  end
}

# repl :: IO Bool
repl = println[">>>"] >> getln >> evaluate

# main :: IO ()
main = whileM[repl]

main.perform!
