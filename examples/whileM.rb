require_relative "support"

include Rubio::Expose

module WhileM
  # whileM :: IO Boolean -> IO ()
  whileM = expose :whileM, ->(f) {
    f >> ->(continue) {
      if continue
        whileM[f]
      else
        pureIO[nil]
      end
    }
  }
end
