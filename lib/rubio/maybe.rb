require "rubio/either"

module Rubio
  module Maybe
    class JustClass < Either::RightClass
      def inspect
        "Just #{@value.inspect}"
      end

      def deconstruct
        [@value]
      end
    end

    class NothingClass < Either::LeftClass
      def initialize
        super(nil)
      end

      def inspect
        "Nothing"
      end

      def deconstruct
        []
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
