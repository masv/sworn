require "simple_oauth"

module Sworn
  class Middleware
    attr_reader :consumers, :access_tokens, :max_drift

    def initialize(app, options = {})
      @app = app
      @consumers      = options.fetch(:consumers) { Hash.new }
      @access_tokens  = options.fetch(:access_tokens) { Hash.new }
      @max_drift      = options.fetch(:max_drift) { 30 }
    end

    def call(env)
      request = Rack::Request.new(env)
      oauth = SimpleOAuth::Header.parse(env['HTTP_AUTHORIZATION'])

      return bad_request    if oauth.empty?
      return not_authorized if expired?(oauth)
      return not_authorized unless valid?(oauth, request)

      return @app.call(env)
    end

    def expired?(oauth)
      timestamp = oauth.fetch(:timestamp).to_i
      now = Time.now.to_i
      window = (now - max_drift .. now + max_drift)
      !window.include?(timestamp)
    end

    def valid?(oauth, request)
      consumer_key = oauth[:consumer_key]
      consumer_secret = consumers[consumer_key]
      access_token = oauth[:token]
      token_secret = access_tokens[access_token]

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
