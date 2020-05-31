require "erubis"

module Rackio
  module Core
    extend Rubio::Expose
    extend Rubio::IO::Core

    render = expose :render, ->(template_path, locals) {
      withFile[template_path]["r"][readFile] >> ->(template) {
        pureIO[ Erubis::Eruby.new(template).result(locals) ]
      }
    }.curry
  end

  class GlueLayer
    include Rubio::State::Core

    def initialize(main, initial_state)
      @main = main
      @state = initial_state
    end

    def call(env)
      io_response, @state = runState[ @main[env] ][ @state ]
      io_response.perform!
    end
  end
end
