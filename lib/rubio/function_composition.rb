module Rubio
  module Composable
    def >(other)
      case 
      when other.respond_to?(:call)
        proc { |*x| other.call( self.call(*x) ) }
      else
        raise ArgumentError, "expected callable, got #{other.class}"
      end
    end

    def <(other)
      case 
      when other.respond_to?(:call)
        proc { |*x| self.call( other.call(*x) ) }
      else
        raise ArgumentError, "expected callable, got #{other.class}"
      end
    end
  end
end

class Proc
  include Rubio::Composable
end

class Method
  include Rubio::Composable
end
