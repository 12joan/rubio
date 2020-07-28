module Rubio
  module Maybe
    class JustClass
      def initialize(value)
        @value = value
      end

      def >>(f)
        f[@value]
      end

      def fmap(f)
        JustClass.new( f[@value] )
      end

      def get!
        @value
      end

      def get_or_else(_)
        get!
      end

      def inspect
        "Just #{@value.inspect}"
      end

      # Provides support for Ruby 2.7 pattern matching
      def deconstruct
        [@value]
      end
    end

    class NothingClass
      def >>(f)
        NothingClass.new
      end

      def fmap(f)
        NothingClass.new
      end

      def get!
        nil
      end

      def get_or_else(x)
        x
      end

      def inspect
        "Nothing"
      end
    end
  end
end
