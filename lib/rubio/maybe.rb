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
    end
  end
end
