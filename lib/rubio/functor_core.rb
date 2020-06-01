module Rubio
  module Functor
    module Core
      extend Expose

      fmap = ->(f, x) {
        x.fmap(f)
      }.curry

      expose :fmap, fmap
    end
  end
end
