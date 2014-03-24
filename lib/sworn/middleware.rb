require "simple_oauth"

module Sworn
  class Middleware
    attr_reader :consumers, :access_tokens

    def initialize(app, options = {})
      @app = app
      @consumers = options.fetch(:consumers) { Hash.new }
      @access_tokens = options.fetch(:access_tokens) { Hash.new }
    end

    def call(env)
      request = Rack::Request.new(env)

      oauth = SimpleOAuth::Header.parse(env['HTTP_AUTHORIZATION'])
      return bad_request if oauth.empty?

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

      return not_authorized unless valid

      return @app.call(env)
    end

    def bad_request
      [400, {}, []]
    end

    def not_authorized
      [401, {}, []]
    end
  end
end
