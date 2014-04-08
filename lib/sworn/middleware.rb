require "simple_oauth"

module Sworn
  class Middleware
    attr_reader :verifier_class

    def initialize(app, options = {})
      @app = app
      @verifier_class = options.fetch(:verifier_class) { Verifier }
    end

    def call(env)
      request = Rack::Request.new(env)
      verifier = verifier_class.new(request)

      return bad_request    if verifier.unsigned?
      return not_authorized if verifier.expired?
      return not_authorized if verifier.replayed?
      return not_authorized unless verifier.valid?

      return @app.call(env)
    end

    def bad_request
      [400, {}, ["Bad request"]]
    end

    def not_authorized
      [401, {}, ["Not authorized"]]
    end
  end
end
