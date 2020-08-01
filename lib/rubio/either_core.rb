module Rubio
  class Either
    module Core
      extend Expose

      Right = ->(x) {
        RightClass.new(x)
      }

      Left = ->(x) {
        LeftClass.new(x)
      }

      pureEither = Right

      expose :Right, Right
      expose :Left, Left
      expose :pureEither, pureEither
    end
  end
end
