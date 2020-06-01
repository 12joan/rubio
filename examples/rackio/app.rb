require_relative "rackio"

module Application
  extend Rubio::Expose
  extend Rubio::State::Core
  extend Rubio::Functor::Core
  extend Rackio::Core

  initialState = expose :initialState, { "hint" => "Try setting a query parameter in the URL" }

  # body :: Env -> Hash -> IO String
  body = ->(env, state) {
    render["index.erb", binding]
  }.curry

  # responseWithBody :: String -> Response
  responseWithBody = ->(body) {
    [200, {"Content-Type" => "text/html"}, [body]]
  }

  # response :: Env -> Hash -> IO Response
  response = (fmap[responseWithBody] << body).curry(2)

  # Merge query parameters with the state hash
  updateState = ->(env) {
    modify[ ->(state) {
      request = Rack::Request.new(env)
      state.merge(request.params)
    }]
  }

  # main :: Env -> State s (IO Response)
  main = expose :main, ->(env) {
    updateState[env] >> gets[ response[env] ]
  }
end
