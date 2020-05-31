module Rubio
  class IO
    module Core
      extend Expose

      pureIO = expose :pureIO, ->(x) {
        IO.pure(x)
      }

      println = expose :println, ->(x) {
        IO.new { puts x }
      }

      getln = expose :getln, IO.new { gets }

      openFile = expose :openFile, ->(path, mode) {
        IO.new { open(path, mode) }
      }.curry

      hClose = expose :hClose, ->(handle) {
        IO.new { handle.close }
      }

      readFile = expose :readFile, ->(handle) {
        Rubio::IO.new { handle.read }
      }

      bracket = expose :bracket, ->(acquire, release, process) {
        acquire >> ->(resource) {
          process[resource] >> ->(result) {
            release[resource] >> pureIO[result]
          }
        }
      }.curry

      withFile = expose :withFile, ->(path, mode) {
        bracket[ openFile[path, mode] ][hClose]
      }.curry
    end
  end
end
