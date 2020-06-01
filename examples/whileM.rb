require_relative "support"

module WhileM
  extend Rubio::Expose

  # whileM :: IO Boolean -> IO ()
  whileM = ->(f) {
    f >> ->(continue) {
      if continue
        whileM[f]
      else
        pureIO[nil]
      end
    }
  }

  expose :whileM, whileM
end
