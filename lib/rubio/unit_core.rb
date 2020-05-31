module Rubio
  module Unit
    module Core
      extend Rubio::Expose

      unit = expose :unit, UnitClass.new
    end
  end
end
