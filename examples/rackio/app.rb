require_relative "rackio"

module Application
  extend Rubio::Expose
  extend Rubio::State::Core
  extend Rackio::Core

  # body :: Env -> StateIO Hash IO String
  body = ->(env) {
    getIO >> ->(state) {
      (liftIO << render)["index.erb", {state: state, env: env}]
    }
  }

  # responseWithBody :: String -> Response
  responseWithBody = ->(body) {
    [200, {"Content-Type" => "text/html"}, [body]]
  }

  # updateState :: Env -> StateIO Hash IO ()
  updateState = ->(env) {
    modifyIO[ ->(state) {
      request = Rack::Request.new(env)
      state.merge(request.params)
    }]
  }

  # main :: Env -> StateIO s IO Response
  expose :main, ->(env) {
    updateState[env] >> body[env] >> (pureStateIO << responseWithBody)
  }

  expose :initialState, { "hint" => "Try setting a query parameter in the URL" }
end
