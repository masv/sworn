module Sworn
  class Configuration
    # A hash of consumer keys and their secrets
    attr_accessor :consumers

    # Maximum timestamp drift allowed
    attr_accessor :max_drift

    # A Proc that takes an OAuth options hash and returns true if the request
    # is replayed, and false if it is not
    attr_accessor :replay_check

    # A hash of access tokens and their secrets
    attr_accessor :tokens

    def initialize
      @consumers    = Hash.new
      @max_drift    = 30
      @replay_check = lambda { |_| false }
      @tokens       = Hash.new
    end
  end
end
