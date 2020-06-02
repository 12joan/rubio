module Rubio
  module State
    class StateClass
      include Unit::Core

      def initialize(f = nil, prior_state_functions: [])
        subsequent_state_functions = if f.nil?
          []
        else
          [ ->(_) { f } ]
        end

        @state_functions = prior_state_functions + subsequent_state_functions
      end

      def >>(other)
        bind case
        when other.is_a?(StateClass)
          other.state_functions
        when other.respond_to?(:call)
          [ ->(r) { other.call(r).run } ]
        else
          raise ArgumentError, "expected State or callable, got #{other.class}"
        end
      end

      def run
        ->(s0) {
          @state_functions.inject( [unit, s0] ) { |z, f|
            r, s = z
            f[r][s]
          }
        }
      end

      def inspect
        "State"
      end

      protected

      def state_functions
        @state_functions
      end

      private

      def bind(subsequent_state_functions)
        StateClass.new(
          prior_state_functions: self.state_functions + subsequent_state_functions
        )
      end
    end
  end
end
