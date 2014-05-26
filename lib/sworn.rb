require "sworn/configuration"
require "sworn/middleware"
require "sworn/replay_protector/custom"
require "sworn/replay_protector/memory"
require "sworn/replay_protector/redis"
require "sworn/verifier"
require "sworn/version"

module Sworn
  class << self
    def configure
      yield(configuration)
    end

    def configuration
      @configuration ||= Configuration.new
    end
  end
end
