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

      def inspect
        "Just #{@value.inspect}"
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

      def inspect
        "Nothing"
      end
    end
  end
end
