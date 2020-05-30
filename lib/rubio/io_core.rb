module Rubio
  class IO
    module Core
      extend Expose

      pure = expose :pure, ->(x) {
        IO.pure(x)
      }

      println = expose :println, ->(x) {
        IO.new { puts x }
      }

      getln = expose :getln, IO.new { gets }

      fmap = expose :fmap, ->(f, x) {
        x.fmap(f)
      }.curry

      openFile = expose :openFile, ->(path, mode) {
        IO.new { open(path, mode) }
      }.curry

      hClose = expose :hClose, ->(handle) {
        IO.new { handle.close }
      }
    end
  end
end
