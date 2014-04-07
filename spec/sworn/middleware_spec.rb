require 'spec_helper'
require 'rack/test'
require 'simple_oauth'

describe Sworn::Middleware do
  include Rack::Test::Methods

  def dummy_app
    lambda { |_| [200, {}, "Hello"] }
  end

  def app
    Sworn::Middleware.new dummy_app, :consumers => { "consumer" => "consumersecret" },
                                     :access_tokens => { "token" => "tokensecret" },
                                     :max_drift => 30 # seconds
  end

  def oauth_signature(options = {})
    method = options.delete(:method) { "GET" }
    url    = options.delete(:url) { "http://example.org/" }
    params = options.delete(:params) { Hash.new }

    options[:consumer_key]    ||= "consumer"
    options[:consumer_secret] ||= "consumersecret"

    SimpleOAuth::Header.new(method, url, params, options)
  end

  it "returns 400 when signature is missing" do
    get "/"
    last_response.status.must_equal 400
  end

  it "returns 401 when signature is invalid" do
    get "/", {}, { 'HTTP_AUTHORIZATION' => 'OAuth oauth_consumer_key="invalid", oauth_token="", oauth_nonce="abc", oauth_timestamp="123", oauth_signature_method="HMAC-SHA1", oauth_version="1.0", oauth_signature="nowayjose"' }
    last_response.status.must_equal 401
  end

  it "returns 401 when signature timestamp is out of bounds" do
    get "/", {}, { 'HTTP_AUTHORIZATION' => oauth_signature(:timestamp => (Time.now.to_i - 60).to_s) }
    last_response.status.must_equal 401
  end

  it "returns 200 for valid consumer-only signature" do
    get "/", {}, { 'HTTP_AUTHORIZATION' => oauth_signature }
    last_response.status.must_equal 200
  end

  it "returns 200 for valid consumer + access token signature" do
    get "/", {}, { 'HTTP_AUTHORIZATION' => oauth_signature(:token => "token", :token_secret => "tokensecret") }
    last_response.status.must_equal 200
  end
end
