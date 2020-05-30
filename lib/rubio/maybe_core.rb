module Rubio
  module Maybe
    module Core
      extend Expose

      Just = expose :Just, ->(x) {
        JustClass.new(x)
      }

      Nothing = expose :Nothing, NothingClass.new

      pureMaybe = expose :pureMaybe, Just
    end
  end
end
