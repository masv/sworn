require "sworn/configuration"
require "sworn/middleware"
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
