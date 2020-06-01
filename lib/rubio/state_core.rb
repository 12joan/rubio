module Rubio
  module State
    module Core
      extend Expose
      extend Unit::Core

      State = ->(f) {
        StateClass.new(f)
      }

      pureState = ->(x) {
        State[ ->(s) {
          [x, s]
        }]
      }

      get = State[ ->(s) {
        [s, s]
      }]

      put = ->(x) {
        State[ ->(s) {
          [unit, x]
        }]
      }

      modify = ->(f) {
        get >> ->(x) {
          put[ f[x] ]
        }
      }

      gets = ->(f) {
        get >> ->(x) {
          pureState[ f[x] ]
        }
      }

      runState = proc(&:run)

      evalState = ->(act) {
        proc(&:first) << runState[act]
      }

      execState = ->(act) {
        proc(&:last) << runState[act]
      }

      expose :State, State
      expose :pureState, pureState
      expose :get, get
      expose :put, put
      expose :modify, modify
      expose :gets, gets
      expose :runState, runState
      expose :evalState, evalState
      expose :execState, execState
    end
  end
end
