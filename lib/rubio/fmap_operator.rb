module Rubio
  module Fmappable
    def %(functor)
      functor.fmap(self)
    end
  end
end

class Proc
  include Rubio::Fmappable
end

class Method
  include Rubio::Fmappable
end
