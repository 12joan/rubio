module Rubio
  module Expose
    def expose(method_name, value)
      define_method(method_name) { value }
      value
    end
  end
end
