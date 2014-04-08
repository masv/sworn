module Sworn
  class Verifier
    attr_accessor :config, :oauth, :request

    def initialize(request, options = {})
      @config = options.fetch(:config) { Sworn.configuration }
      @request = request
      @oauth = SimpleOAuth::Header.parse(request.env["HTTP_AUTHORIZATION"])
    end

    def unsigned?
      oauth.empty?
    end

    def expired?
      timestamp = oauth.fetch(:timestamp).to_i
      now = Time.now.to_i
      window = (now - config.max_drift .. now + config.max_drift)
      !window.include?(timestamp)
    end

    def replayed?
      config.replay_check.call(oauth)
    end

    def valid?
      consumer_key = oauth[:consumer_key]
      consumer_secret = config.consumers[consumer_key]
      access_token = oauth[:token]
      token_secret = config.tokens[access_token]

      valid = SimpleOAuth::Header.new(
        request.request_method,
        request.url,
        request.params,
        oauth
      ).valid?(:consumer_secret => consumer_secret, :token_secret => token_secret)
    end
  end
end
