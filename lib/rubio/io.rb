module Rubio
  class IO
    include Unit::Core

    def initialize(prior_actions = [], &action)
      block_actions = if action.nil?
        []
      else
        [ ->(_) { action.call } ]
      end

      @actions = prior_actions + block_actions
    end

    def >>(other)
      bind case
      when other.is_a?(IO)
        other.actions
      when other.respond_to?(:call)
        [ ->(x) { other.call(x).perform! } ]
      else
        raise ArgumentError, "expected IO or callable, got #{other.class}"
      end 
    end

    def fmap(f) 
      self >> (IO.method(:pure) << f)
    end

    def perform!
      @actions.inject( IO.pure(unit) ) { |z, action|
        action[z]
      }
    end

    def self.pure(x)
      IO.new { x }
    end

    def inspect
      "IO"
    end

    protected

    def actions
      @actions
    end

    private

    def bind(subsequent_actions)
      IO.new(self.actions + subsequent_actions)
    end
  end
end
