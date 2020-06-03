# Rubio

[![GitHub version](https://badge.fury.io/gh/12joan%2Frubio.svg)](https://badge.fury.io/gh/12joan%2Frubio) [![Build Status](https://travis-ci.com/12joan/rubio.svg?branch=master)](https://travis-ci.com/12joan/rubio) [![Maintainability](https://api.codeclimate.com/v1/badges/e435a25bf4b6197b464e/maintainability)](https://codeclimate.com/github/12joan/rubio/maintainability) [![Coverage Status](https://coveralls.io/repos/github/12joan/rubio/badge.svg?branch=master)](https://coveralls.io/github/12joan/rubio?branch=master)

Write pure, functional code that encapsulates side effects using the IO monad (and friends) in Ruby.

## Contents

- [1. Installation](#1-installation)
- [2. Usage and syntax](#2-usage-and-syntax)
  - [2.1 `main :: IO`](#21-main--io)
  - [2.2 `>>` operator for monads](#22--operator-for-monads)
  - [2.3 Function composition](#23-function-composition)
  - [2.4 Partially applying functions in Ruby](#24-partially-applying-functions-in-ruby)
  - [2.5 `%` operator](#25--operator)
  - [2.6 Expose/extend pattern](#26-exposeextend-pattern)
- [3. Built-in modules](#3-built-in-modules)
  - [3.1 `Rubio::IO::Core`](#31-rubioiocore)
    - [3.1.1 Limitations](#311-limitations)
    - [3.1.2 Built-in functions](#312-built-in-functions)
  - [3.2 `Rubio::Maybe::Core`](#32-rubiomaybecore)
    - [3.2.1 Unwraping `Maybe a -> a`](#321-unwraping-maybe-a---a)
      - [3.2.1.1 Ruby < 2.7](#3211-ruby--27)
      - [3.2.1.2 Ruby >= 2.7](#3212-ruby--27)
    - [3.2.2 Built-in functions](#322-built-in-functions)
  - [3.3 `Rubio::State::Core`](#33-rubiostatecore)
    - [3.3.1 Built-in functions](#331-built-in-functions)
      - [3.3.1.1 `State`](#3311-state)
      - [3.3.1.2 `StateIO`](#3312-stateio)
  - [3.4 `Rubio::Unit::Core`](#34-rubiounitcore)
    - [3.4.1 Built-in functions](#341-built-in-functions)
  - [3.5 `Rubio::Functor::Core`](#35-rubiofunctorcore)
    - [3.5.1 Built-in functions](#351-built-in-functions)
  - [3.6 `Rubio::Expose`](#36-rubioexpose)
- [4. Examples](#4-examples)

## 1. Installation

Add the following line to your Gemfile.

```ruby
gem "rubio", github: "12joan/rubio"
```

## 2. Usage and syntax

### 2.1 `main :: IO`

All programs written using Rubio are encouraged to construct and then invoke a `main` value which describes the entire behaviour of the program. `IO#perform!` is the equivalent of [`unsafePerformIO`](https://hackage.haskell.org/package/base-4.9.0.0/docs/System-IO-Unsafe.html#v:unsafePerformIO)  in Haskell, and must be explicitly called at the bottom of the program in order for the program to run. 

```ruby
require "rubio"

include Rubio::IO::Core

# agree :: String -> String
agree = ->(favourite) {
  "I like the #{favourite.chomp} monad too! 🙂"
}

# main :: IO
main = println["What's your favourite monad?"] >> getln >> (println << agree)
main.perform!
```

`Rubio::IO::Core` provides a number of standard IO operations, such as `println` and `getln`. 

### 2.2 `>>` operator for monads

Monads are "composed" using the `>>` (bind) operator. Note that unlike in Haskell,  `>>`  behaves differently depending on whether the right operand is a function or a monad. 

```haskell
-- When the right operand is a function (equivalent to (>>=) in Haskell)
(>>) :: Monad m => m a -> (a -> m b) -> m b

-- When the right operand is a monad (equivalent to (>>) in Haskell)
(>>) :: Monad m => m a -> m b -> m b
```

For example:

- `println["hello"] >> println["world"]` returns a single `IO` which, when performed, will output "hello" and then "world". 
- `getln >> println` returns an IO which prompts for user input (as per `Kernel#gets`) and passes the result to `println`.
- `getln >> ->(x) { println[x] }` is equivalent to `getln >> println`.

Note that whereas `getln` is a value of type `IO`, `println` is a function of type `String -> IO`. 

### 2.3 Function composition

Ruby Procs can be composed using the built-in `>>` and `<<` operators. 

```ruby
add10 = ->(x) { x + 10 }
double = ->(x) { x * 2 }

add10_and_double = double << add10
double_and_add10 = double >> add10

add10_and_double[5] #=> 30
double_and_add10[5] #=> 20
```

### 2.4 Partially applying functions in Ruby

Ruby `Proc`s are not curried by default. In order to partially apply a function, you must first call `Proc#curry` on it. 

```ruby
add = ->(x, y) {
  x + y
}.curry

add[6, 4] #=> 10
add[6][4] #=> 10

add10 = add[10] 

add10[5] #=> 15
```

### 2.5 `%` operator

Rubio monkey patches the `%` operator, which is an alias for `fmap`, onto `Proc` and `Method`. 

```ruby
include Rubio::Maybe::Core

reverse = proc(&:reverse)

reverse % Just["Hello"] #=> Just "olleH"
reverse % Nothing #=> Nothing
```

### 2.6 Expose/extend pattern

For a function or value defined in a module to be "includable" (either with `include` or `extend`), it must be wrapped inside a method. 

```ruby
module SomeStandardFunctions
  # not includable
  add = ->(x, y) { x + y }
  
  # includable
  def multiply
    ->(x, y) { x * y }
  end
end

module SomewhereElse
  extend SomeStandardFunctions
  
  add[4, 6] #=> NameError (undefined local variable or method `add' for SomewhereElse:Module)
  
  multiply[4, 6] #=> 24
end
```

To make the syntax for this nicer, Rubio provides the `Rubio::Expose` module. 

```ruby
module SomeStandardFunctions
  extend Rubio::Expose
  
	expose :add,      ->(x, y) { x + y }
  expose :multiply, ->(x, y) { x * y }
end

module SomewhereElse
  extend SomeStandardFunctions
  
  add[4, 6] #=> 10
  multiply[4, 6] #=> 24
end
```

## 3. Built-in modules

### 3.1 `Rubio::IO::Core`

#### 3.1.1 Limitations

Currently, the `Rubio::IO::Core` module provides a limited subset of the functionality available via calling methods on `Kernel`. Custom `IO` operations can be defined as follows. 

```ruby
# runCommand :: String -> IO String
runCommand = ->(cmd) {
  Rubio::IO.new { `#{cmd}` }
}
```

#### 3.1.2 Built-in functions

- `pureIO :: a -> IO a`
  
  Wraps a value in the `IO` monad.
  
  ```ruby
  include Rubio::IO::Core
  
  # io :: IO Integer
  io = pureIO[5]
  io.perform! #=> 5
  ```
  
  Useful for adhering to the contract of the bind operator. In the example below, the anonymous function defined on `input` takes a `String` and returns an `IO String`. 
  
  ```ruby
  include Rubio::IO::Core
  
  main = getln >> ->(input) { pureIO[input.reverse] } >> println
  main.perform!
  ```
  
- `println :: String -> IO`

  Encapsulates `Kernel#puts`. 

  ```ruby
  include Rubio::IO::Core
  
  main = println["Hello world!"]
  main.perform!
  ```

  ```ruby
  include Rubio::IO::Core
  
  main = pureIO["This works too!"] >> println
  main.perform!
  ```

- `getln :: IO`

  Encapsulates `Kernel#gets`.

  ```ruby
  include Rubio::IO::Core
  
  doSomethingWithUserInput = ->(input) {
    println["You just said: #{input}"]
  }
  
  main = getln >> doSomethingWithUserInput
  main.perform!
  ```

- `openFile :: String -> String -> IO File`

  Encapsulates `Kernel#open`. First argument is the path to the file; second argument is the mode.

  ```ruby
  include Rubio::IO::Core
  
  # io :: IO File
  io = openFile["README.md", "r"]
  io.perform! #=> #<File:README.md>
  ```

  ```ruby
  require "open-uri"
  
  include Rubio::IO::Core
  
  main = openFile["https://ifconfig.me"]["r"] >> ->(handle) {
    readFile[handle] >> println >> hClose[handle]
  }
  
  main.perform! #=> "216.58.204.5"
  ```

- `hClose :: File -> IO`

  Encapsulates `File#close`. Note that `withFile` is generally preferred.

- `readFile :: File -> IO String`

  Encapsulates `File#read`.

  ```ruby
  include Rubio::IO::Core
  
  # ...
  # someFile :: IO File
  
  main = someFile >> readFile >> println
  main.perform! #=> "Contents of someFile"
  ```

- `bracket :: IO a -> (a -> IO b) -> (a -> IO c) -> IO c`

  Pattern to automatically acquire a resource, perform a computation, and then release the resource. 

  The first argument is performed to acquire the resource of type `a`. The resource is then passed to the third argument. This returns an `IO c`, which will eventually be returned by `bracket`. Finally, the second argument is called to release the resource. 

  This pattern is used by `withFile` to automatically close the file handle. 

  ```ruby
  include Rubio::IO::Core
  
  # withFile :: String -> String -> (File -> IO a) -> IO a
  withFile = ->(path, mode) {
    bracket[ openFile[path, mode] ][ hClose ]
  }.curry
  
  withFile["README.md", "r"][readFile] #=> IO String
  ```

- `withFile :: String -> String -> (File -> IO a) -> IO a`

  Acquires a file handle, performs a computation, and then closes the file handle.

  ```ruby
  require "open-uri"
  
  include Rubio::IO::Core
  
  main = withFile["https://ifconfig.me"]["r"][readFile] >> println
  main.perform! #=> "216.58.204.5"
  ```

### 3.2 `Rubio::Maybe::Core`

#### 3.2.1 Unwraping `Maybe a -> a`

##### 3.2.1.1 Ruby < 2.7

`Maybe#get!` will return `x` in the case of `Just[x]`, or `nil` in the case of `Nothing`. 

If you call `get!`, you should explicitly handle the case where `get!` returns `nil`. 

```ruby
include Rubio::Maybe::Core

doSomethingWithMaybe = ->(maybe) {
  case
  when x = maybe.get!
    "You got #{x}!"
  else
    "You got nothing."
  end
}

doSomethingWithMaybe[ Just["pattern matching"] ] #=> "You got pattern matching!"
doSomethingWithMaybe[ Nothing ] #=> "You got nothing."
```

```ruby
include Rubio::Maybe::Core

orEmptyString = ->(maybe) {
  maybe.get! || ""
}

orEmptyString[ Just["hello"] ] #=> "hello"
orEmptyString[ Nothing ] #=> ""
```

Note that if `x` is a "falsey" value, such as `false` or `nil`, you must explicitly check for `Rubio::Maybe::JustClass` or `Rubio::Maybe::NothingClass`. 

```ruby
include Rubio::Maybe::Core

doSomethingWithMaybe = ->(maybe) {
  case maybe
  when Rubio::Maybe::JustClass
    "You got #{maybe.get!}!"
  when Rubio::Maybe::NothingClass
    "You got nothing."
  end
}

doSomethingWithMaybe[ Just[false] ] #=> "You got false!"
doSomethingWithMaybe[ Nothing ] #=> "You got nothing."
```

##### 3.2.1.2 Ruby >= 2.7

Ruby 2.7 introduces support for pattern matching, which allows for much nicer syntax when working with `Maybe`. 

```ruby
include Rubio::Maybe::Core

doSomethingWithMaybe = ->(maybe) {
  case maybe
  in Just[x]
    "You got #{x}!"
  in Nothing
    "You got nothing."
  end
}

doSomethingWithMaybe[ Just["even better pattern matching"] ] #=> "You got even better pattern matching!"
doSomethingWithMaybe[ Nothing ] #=> "You got nothing."
```

#### 3.2.2 Built-in functions

- `Just :: a -> Maybe a`

  Constructs a `Just` value for the given argument. 

  ```ruby
  include Rubio::Maybe::Core
  
  maybe = Just[5]
  maybe.inspect #=> "Just 5"
  ```

- `Nothing :: Maybe`

  Singleton `Nothing` value. 

  ```ruby
  include Rubio::Maybe::Core
  
  divide = ->(x, y) {
    if y == 0
      Nothing
    else
      Just[x / y]
    end
  }.curry
  
  divide[12, 2] #=> Just 6
  divide[12, 0] #=> Nothing
  
  double = ->(x) { x * 2 }
  
  double % divide[12, 2] #=> Just 12
  double % divide[12, 0] #=> Nothing
  ```

- `pureMaybe :: a -> Maybe a`

  Alias for `Just`.

  ```ruby
  include Rubio::Maybe::Core
  
  maybe1 = Just[5]
  maybe1.inspect #=> "Just 5"
  
  maybe2 = pureMaybe[5]
  maybe2.inspect #=> "Just 5"
  ```

### 3.3 `Rubio::State::Core`

#### 3.3.1 Built-in functions

##### 3.3.1.1 `State`

- `State :: (s -> (a, s)) -> State s a`

  Constructs a `State` object with the given function. Note that since Ruby does not support tuples, you are expected to use an `Array` as the return value of the function. 

  ```ruby
  include Rubio::State::Core
  include Rubio::Unit::Core
  
  # push :: a -> State [a] ()
  push = ->(x) { State[
    ->(xs) { [unit, [x] + xs] }
  ]}
  
  # pop :: State [a] a
  pop = State[
    ->(xs) { [ xs.first, xs.drop(1) ] }
  ]
  
  # pop :: State [a] a
  complexOperation = push[1] >> push[2] >> push[3] >> pop
  
  runState[ complexOperation ][ [10, 11] ] #=> [3, [2, 1, 10, 11]]
  ```

  Often, composing `State` objects using the functions listed below is preferable to calling the `State` constructor directly.
  
- `pureState :: a -> State s a`

  Constructs a `State` object which sets the result and leaves the state unchanged.

  ```ruby
  include Rubio::State::Core
  
  # operation :: State s Integer
  operation = pureState[123]
  runState[ operation ][ "initial state" ] #=> [123, "initial state"]
  ```

- `get :: State s s`

  A `State` object that sets the result equal to the state.

  ```ruby
  include Rubio::State::Core
  
  # operation1 :: State s Integer
  operation1 = pureState[123]
  runState[ operation1 ][ "initial state" ] #=> [123, "initial state"]
  
  # operation2 :: State s s
  operation2 = pureState[123] >> get
  runState[ operation2 ][ "initial state" ] #=> ["initial state", "initial state"]
  ```

  Often used to retrieve the current state just before `>>`. 

  ```ruby
  include Rubio::State::Core
  
  # operation :: State [a] [a]
  operation = get >> ->(state) {
    pureState[state.reverse]
  }
  
  runState[ operation ][ "initial state" ] #=> ["etats laitini", "initial state"]
  ```

- `put :: s -> State s ()`

  Constructs a `State` object which sets the state.

  ```ruby
  include Rubio::State::Core
  
  # operation :: State String ()
  operation = put["new state"]
  runState[ operation ][ "initial state" ] #=> [(), "new state"]
  ```

- `modify :: (s -> s) -> State s ()`

  Constructs a `State` object which applies the function to the state.

  ```ruby
  include Rubio::State::Core
  
  # reverse :: [a] -> [a]
  reverse = proc(&:reverse)
  
  # operation :: State [a] ()
  operation = modify[reverse]
  runState[ operation ][ "initial state" ] #=> [(), "etats laitini"]
  ```

- `gets :: (s -> a) -> State s a`

  Constructs a `State` object that sets the result equal to `f[s]`, where `f` is the given function and `s` is the state.

  ```ruby
  include Rubio::State::Core
  
  # count :: [a] -> Integer
  count = proc(&:count)
  
  # operation :: State [a] Integer
  operation = gets[count]
  runState[ operation ][ [1, 2, 3, 4, 5] ] #=> [5, [1, 2, 3, 4, 5]]
  ```

- `runState :: State s a -> s -> (a, s)`

  Runs a `State` object against an initial state. Returns a tuple containing the final result and the final state. 

  ```ruby
  include Rubio::State::Core
  
  # push :: a -> State [a] ()
  push = ->(x) {
    modify[ ->(xs) {
      [x] + xs
    }]
  }
  
  head = proc(&:first)
  tail = ->(xs) { xs.drop(1) }
  
  # pop :: State [a] a
  pop = gets[head] >> ->(x) {
    modify[tail] >> pureState[x]
  }
  
  # operation :: State [a] ()
  operation = pop >> ->(a) {
    pop >> ->(b) {
      push[a] >> push[b]
    }
  }
  
  runState[ operation ][ [1, 2, 3, 4] ] #=> [(), [2, 1, 3, 4]]
  ```

- `evalState :: State s a -> s -> a`

  As per `runState`, except it only returns the final result. 

  ```ruby
  include Rubio::State::Core
  
  # operation :: State String String
  operation = put["final state"] >> pureState["final result"]
  evalState[ operation ][ "initial state" ] #=> "final result"
  ```

- `execState :: State s a -> s -> s`

  As per `runState`, except it only returns the final state. 

  ```ruby
  include Rubio::State::Core
  
  # operation :: State String String
  operation = put["final state"] >> pureState["final result"]
  execState[ operation ][ "initial state" ] #=> "final state"
  ```
  
##### 3.3.1.2 `StateIO`

- `StateIO :: (s -> IO (a, s)) -> StateIO s IO a`

  `IO` variety of `State`.

  ```ruby
  include Rubio::State::Core
  include Rubio::IO::Core
  
  operation = StateIO[
    ->(s) {
      println["The current state is #{s.inspect}"] >> pureIO[ ["result", s.reverse] ]
    }
  ]
  
  io = runStateT[operation][ [1, 2, 3] ] #=> IO
  io.perform!
  # The current state is [1, 2, 3]
  #=> ["result", [3, 2, 1]] 
  ```
  
- `liftIO :: IO a -> StateIO s IO a`

  Lift an `IO` into the `StateIO` monad. Useful for performing `IO` operations during a computation.

  ```ruby
  include Rubio::State::Core
  include Rubio::IO::Core
  
  operation = (liftIO << println)["Hello world!"]
  
  io = execStateT[operation][ [1, 2, 3] ] #=> IO
  io.perform!
  # Hello world!
  #=> [3, 2, 1]
  ```

- `pureStateIO :: a -> StateIO s IO a`

  `IO` variety of `pureState`.

- `getIO :: StateIO s IO s`

  `IO` variety of `get`.

- `putIO :: s -> StateIO s IO ()`

  `IO` variety of `put`.

- `modifyIO :: (s -> s) -> StateIO s IO ()`

  `IO` variety of `modify.`
  
- `getsIO :: (s -> a) -> StateIO s a`

  `IO` variety of `gets`.
  
- `runStateT -> StateIO s IO a -> s -> IO (a, s)`

  `IO` variety of `runState`.

  ```ruby
  include Rubio::State::Core
  include Rubio::IO::Core
  
  operation = putIO["final state"] >> pureStateIO["final result"]
  
  io = runStateT[ operation ][ "initial state" ] #=> IO
  io.perform! #=> ["final result", "final state"]
  ```

- `evalStateT :: StateIO s IO a -> s -> IO a`

  `IO` variety of `evalState`.
  
  ```ruby
  include Rubio::State::Core
  include Rubio::IO::Core
  
  operation = putIO["final state"] >> pureStateIO["final result"]
  
  io = evalStateT[ operation ][ "initial state" ] #=> IO
  io.perform! #=> "final result"
  ```

- `execStateT :: StateIO s IO a -> s -> IO s`

  `IO` variety of `execState`.

  ```ruby
  include Rubio::State::Core
  include Rubio::IO::Core
  
  operation = putIO["final state"] >> pureStateIO["final result"]
  
  io = execStateT[ operation ][ "initial state" ] #=> IO
  io.perform! #=> "final state"
  ```

### 3.4 `Rubio::Unit::Core`

#### 3.4.1 Built-in functions

- `unit :: ()`

  Singleton `()` value.

  ```ruby
  include Rubio::Unit::Core
  
  unit.inspect #=> "()"
  ```

### 3.5 `Rubio::Functor::Core`

#### 3.5.1 Built-in functions

- `fmap :: Functor f => (a -> b) -> f a -> f b`

  Calls `fmap` on the second argument with the given function.

  ```ruby
  include Rubio::Functor::Core
  include Rubio::IO::Core
  
  io1 = pureIO["Hello"]
  
  reverse = proc(&:reverse)
  
  io2 = fmap[reverse][io1]
  io2.perform! #=> "olleH"
  ```
  
  ```ruby
  include Rubio::Functor::Core
  include Rubio::Maybe::Core
  
  reverse = proc(&:reverse)
  
  fmap[reverse][ Just["Hello"] ] #=> Just "olleH"
  fmap[reverse][ Nothing ] #=> Nothing
  ```
  
  ```ruby
  include Rubio::Functor::Core
  
  CustomType = Struct.new(:value) do
    def fmap(f)
      self.class.new( f[value] )
    end
  end
  
  obj = CustomType.new("Hello")
  
  reverse = proc(&:reverse)
  
  fmap[reverse][obj] #=> #<struct CustomType value="olleH">
  ```
  
  Note that the infix `%` operator can also be used without including `Rubio::Functor::Core`. 
  
  ```ruby
  include Rubio::Maybe::Core
  
  reverse = proc(&:reverse)
  
  reverse % Just["Hello"] #=> Just "olleH"
  reverse % Nothing #=> Nothing
  ```
  
### 3.6 `Rubio::Expose`

#### 3.6.1 Methods

- `expose(method_name, value) -> value`

  Defines a getter method for the given value.

  ```ruby
  module StdMath
    extend Rubio::Expose
    
    add = ->(x, y) { x + y }.curry
    instance_methods.include?(:add) #=> false
    
    expose :add, add
    instance_methods.include?(:add) #=> true
  end
  
  include StdMath
  
  add[3, 4] #=> 7
  ```

## 4. Examples

- [examples/fizz_buzz.rb](examples/fizz_buzz.rb) - Examples of basic functional programming, basic IO, Maybe, fmap
- [examples/repl.rb](examples/repl.rb) and [examples/whileM.rb](examples/whileM.rb) - Custom includable modules, looping, more nuanced use of IO
- [examples/ruby_2.7_pattern_matching.rb](examples/ruby_2.7_pattern_matching.rb) - Using Maybe with the experimental pattern matching syntax in Ruby 2.7
- [examples/rackio/](examples/rackio/) - A small Rack application built using Rubio; uses the StateIO monad to store data in memory that persists between requests
