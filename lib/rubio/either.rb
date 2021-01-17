module Rubio
  class Either
    def initialize(value)
      @value = value
    end

    def get!
      @value
    end

    def ==(other)
      self.class == other.class && @value == other.get!
    end

    class RightClass < Either
      def >>(f)
        f[@value]
      end

      def fmap(f)
        self.class.new( f[@value] )
      end

      def get_or_else(_)
        get!
      end

      def inspect
        "Right #{@value.inspect}"
      end
    end

    class LeftClass < Either
      def >>(f)
        self
      end

      def fmap(f)
        self
      end

      def get_or_else(x)
        x
      end

      def inspect
        "Left #{@value.inspect}"
      end
    end
  end
end
