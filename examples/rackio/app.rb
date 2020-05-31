require_relative "rackio"

module Application
  extend Rubio::Expose
  extend Rubio::State::Core
  extend Rubio::Functor::Core
  extend Rackio::Core

  initialState = expose :initialState, { "hint" => "Try setting a query parameter in the URL" }

  body = ->(env, state) {
    render["index.erb", binding]
  }.curry

  responseWithBody = ->(body) {
    [200, {"Content-Type" => "text/html"}, [body]]
  }

  response = ->(env, state) {
    fmap[ responseWithBody ][ body[env, state] ]
  }.curry

  # Merge query parameters with the state hash
  updateState = ->(env) {
    modify[ ->(state) {
      request = Rack::Request.new(env)
      state.merge(request.params)
    }]
  }

  # main :: Env -> State s (IO Response)
  main = expose :main, ->(env) {
    updateState[env] >> get >> (pureState << response[env])
  }
end
