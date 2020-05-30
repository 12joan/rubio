module Rubio
  class IO
    def initialize(&action)
      @action = action
    end

    def >>(other)
      case
      when other.is_a?(IO)
        bind ->(_) { other }
      when other.respond_to?(:call)
        bind(other)
      else
        raise ArgumentError, "expected IO or callable, got #{other.class}"
      end
    end

    def bind(other)
      IO.new {
        other.call(perform!).perform!
      }
    end

    def perform!
      @action.call
    end
  end
end
