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

      def ==(other)
        other.is_a?(JustClass) && @value == other.get!
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

      def ==(other)
        other.is_a?(NothingClass)
      end
    end
  end
end

class Object
  def to_maybe
    Rubio::Maybe::JustClass.new(self)
  end
end

class NilClass
  def to_maybe
    Rubio::Maybe::NothingClass.new
  end
end
