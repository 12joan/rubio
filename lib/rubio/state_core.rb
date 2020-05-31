module Rubio
  module State
    module Core
      extend Expose
      extend Unit::Core

      State = expose :State, ->(f) {
        StateClass.new(f)
      }

      pureState = expose :pureState, ->(x) {
        State[ ->(s) {
          [x, s]
        }]
      }

      get = expose :get, State[ ->(s) {
        [s, s]
      }]

      put = expose :put, ->(x) {
        State[ ->(s) {
          [unit, x]
        }]
      }

      modify = expose :modify, ->(f) {
        get >> ->(x) {
          put[ f[x] ]
        }
      }

      gets = expose :gets, ->(f) {
        get >> ->(x) {
          pureState[ f[x] ]
        }
      }

      runState = expose :runState, proc(&:run)

      evalState = expose :evalState, ->(act) {
        proc(&:first) << runState[act]
      }

      execState = expose :execState, ->(act) {
        proc(&:last) << runState[act]
      }
    end
  end
end
