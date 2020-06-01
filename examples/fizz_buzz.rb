require_relative "support"

include Rubio::IO::Core
include Rubio::Maybe::Core

# divisible :: Integer -> Boolean
divisible = ->(x, d) {
  (x % d) == 0
}.curry

# fizzBuzz :: Integer -> String
fizzBuzz = ->(x) {
  x_divisible = divisible[x]

  case
  when x_divisible[15]
    "FizzBuzz"
  when x_divisible[3]
    "Fizz"
  when x_divisible[5]
    "Buzz"
  else
    x.to_s
  end
}

# safeParse :: String -> Maybe Integer
safeParse = ->(str) {
  Just[ Integer(str) ] rescue Nothing
}

# evaluate :: String -> String
evaluate = ->(input) {
  case
  when n = safeParse[input].get!
    fizzBuzz[n]
  else
    "That's not an integer!"
  end
}

# main :: IO ()
main = println["Enter a number..."] >> (evaluate % getln) >> println

main.perform!
