module Rubio
  module Monad
    module Identity
      class IdentityClass
        attr_reader :value

        def initialize(value)
          @value = value
        end

        def >>(other)
          case
          when other.respond_to?(:call)
            other.call(@value)
          else
            raise ArgumentError, "expected callable, got #{other.class}"
          end
        end

        def self.pure(x)
          IdentityClass.new(x)
        end
      end
    end
  end
end
