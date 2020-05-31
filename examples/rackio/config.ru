require_relative "../support"
require_relative "rackio"
require_relative "app"

extend Application

run Rackio::GlueLayer.new(main, initialState)
