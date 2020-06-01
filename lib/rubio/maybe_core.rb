module Rubio
  module Maybe
    module Core
      extend Expose

      Just = ->(x) {
        JustClass.new(x)
      }

      Nothing = NothingClass.new

      pureMaybe = Just

      expose :Just, Just
      expose :Nothing, Nothing
      expose :pureMaybe, pureMaybe
    end
  end
end
