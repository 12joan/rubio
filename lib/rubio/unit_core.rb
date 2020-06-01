module Rubio
  module Unit
    module Core
      extend Rubio::Expose

      unit = UnitClass.new

      expose :unit, unit
    end
  end
end
