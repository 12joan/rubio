module Rubio
  module Functor
    module Core
      extend Expose

      fmap = expose :fmap, ->(f, x) {
        x.fmap(f)
      }.curry
    end
  end
end
