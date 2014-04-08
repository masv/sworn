require "simple_oauth"

module Sworn
  class Middleware
    attr_reader :config

    def initialize(app, options = {})
      @app = app
      @config = options.fetch(:config) { Sworn.configuration }
    end

    def call(env)
      request = Rack::Request.new(env)
      oauth = SimpleOAuth::Header.parse(env['HTTP_AUTHORIZATION'])

      return bad_request    if oauth.empty?
      return not_authorized if expired?(oauth)
      return not_authorized if replayed?(oauth)
      return not_authorized unless valid?(oauth, request)

      return @app.call(env)
    end

    def expired?(oauth)
      timestamp = oauth.fetch(:timestamp).to_i
      now = Time.now.to_i
      window = (now - config.max_drift .. now + config.max_drift)
      !window.include?(timestamp)
    end

    def replayed?(oauth)
      config.replay_check.call(oauth)
    end

    def valid?(oauth, request)
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

    def bad_request
      [400, {}, ["Bad request"]]
    end

    def not_authorized
      [401, {}, ["Not authorized"]]
    end
  end
end
