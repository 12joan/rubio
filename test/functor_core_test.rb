require "test_helper"

class FunctorTest < Minitest::Test
  include Rubio::Functor::Core

  DummyFunctor = Struct.new(:value) {
    def fmap(f)
      DummyFunctor.new f[value]
    end
  }

  test "fmap :: Functor f => (a -> b) -> f a -> f b" do
    functor1 = DummyFunctor.new(42)
    f = ->(x) { x + 10 }
    functor2 = fmap[f][functor1]

    assert_equal 52, functor2.value
  end
end
