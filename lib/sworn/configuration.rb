module Sworn
  class Configuration
    # A hash of consumer keys and their secrets
    attr_accessor :consumers

    # Maximum timestamp drift allowed
    attr_accessor :max_drift

    # A Proc that takes an OAuth options hash and returns true if the request
    # is replayed, and false if it is not
    attr_reader :replay_protector

    def replay_protector=(*args)
      klass, *parameters = args.flatten
      @replay_protector = klass.new(parameters)
    end

    # A hash of access tokens and their secrets
    attr_accessor :tokens

    def initialize
      self.consumers        = Hash.new
      self.max_drift        = 30
      self.tokens           = Hash.new
      self.replay_protector = Sworn::ReplayProtector::Custom, lambda { |_| false }
    end
  end
end
