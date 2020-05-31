module Rubio
  module State
    class StateClass
      def initialize(f)
        @f = f
      end

      def >>(other)
        case
        when other.is_a?(StateClass)
          bind ->(_) { other }
        when other.respond_to?(:call)
          bind(other)
        else
          raise ArgumentError, "expected State or callable, got #{other.class}"
        end
      end

      def bind(other)
        StateClass.new( ->(s) {
          a, new_s = self.run[s]
          other[a].run[new_s]
        })
      end

      def run
        @f
      end

      def inspect
        "State"
      end
    end
  end
end
