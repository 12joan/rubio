module Rubio
  module State
    module Core
      extend Expose
      extend Unit::Core
      extend IO::Core
      extend Functor::Core

      State = ->(f) {
        pureIdentity = ->(x) { Monad::Identity::IdentityClass.pure(x) }
        StateClass.new(pureIdentity << f)
      }

      StateIO = ->(f) {
        StateClass.new(f, monad_state_klass: IO)
      }.curry

      liftIO = ->(x) {
        StateIO[ ->(s) {
          x >> ->(a) {
            pureIO[[a, s]]
          }
        }]
      }

      pureState = ->(x) {
        State[ ->(s) {
          [x, s]
        }]
      }

      pureStateIO = ->(x) {
        StateIO[ ->(s) {
          pureIO[[x, s]]
        }]
      }

      get = State[ ->(s) {
        [s, s]
      }]

      getIO = StateIO[ ->(s) {
        pureIO[ [s, s] ]
      }]

      put = ->(x) {
        State[ ->(s) {
          [unit, x]
        }]
      }

      putIO = ->(x) {
        StateIO[ ->(s) {
          pureIO[ [unit, x] ]
        }]
      }

      modify = ->(f) {
        get >> ->(x) {
          put[ f[x] ]
        }
      }

      modifyIO = ->(f) {
        getIO >> ->(x) {
          putIO[ f[x] ]
        }
      }

      gets = ->(f) {
        get >> ->(x) {
          pureState[ f[x] ]
        }
      }

      getsIO = ->(f) {
        getIO >> ->(x) {
          pureStateIO[ f[x] ]
        }
      }

      runState = ->(state, initial_state) {
        state.run[initial_state].value
      }.curry

      runStateT = ->(state, initial_state) {
        state.run[initial_state]
      }.curry

      evalState = ->(act) {
        proc(&:first) << runState[act]
      }

      evalStateT = ->(act) {
        fmap[proc(&:first)] << runStateT[act]
      }

      execState = ->(act) {
        proc(&:last) << runState[act]
      }

      execStateT = ->(act) {
        fmap[proc(&:last)] << runStateT[act]
      }

      expose :State, State
      expose :StateIO, StateIO
      expose :liftIO, liftIO
      expose :pureState, pureState
      expose :pureStateIO, pureStateIO
      expose :get, get
      expose :getIO, getIO
      expose :put, put
      expose :putIO, putIO
      expose :modify, modify
      expose :modifyIO, modifyIO
      expose :gets, gets
      expose :getsIO, getsIO
      expose :runState, runState
      expose :runStateT, runStateT
      expose :evalState, evalState
      expose :evalStateT, evalStateT
      expose :execState, execState
      expose :execStateT, execStateT
    end
  end
end
