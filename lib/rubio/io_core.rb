module Rubio
  class IO
    module Core
      extend Expose

      pureIO = ->(x) {
        IO.pure(x)
      }

      println = ->(x) {
        IO.new { puts x }
      }

      getln = IO.new { gets }

      openFile = ->(path, mode) {
        IO.new { open(path, mode) }
      }.curry

      hClose = ->(handle) {
        IO.new { handle.close }
      }

      readFile = ->(handle) {
        Rubio::IO.new { handle.read }
      }

      bracket = ->(acquire, release, process) {
        acquire >> ->(resource) {
          process[resource] >> ->(result) {
            release[resource] >> pureIO[result]
          }
        }
      }.curry

      withFile = ->(path, mode) {
        bracket[ openFile[path, mode] ][hClose]
      }.curry

      expose :pureIO, pureIO
      expose :println, println
      expose :getln, getln
      expose :openFile, openFile
      expose :hClose, hClose
      expose :readFile, readFile
      expose :bracket, bracket
      expose :withFile, withFile
    end
  end
end
