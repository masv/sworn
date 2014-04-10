require 'spec_helper'
require 'rack/test'
require 'simple_oauth'

describe Sworn::Middleware do
  include Rack::Test::Methods

  def dummy_app
    lambda { |_| [200, {}, "Hello"] }
  end

  def app
    Sworn.configure do |config|
      config.consumers    = { "consumer" => "consumersecret" }
      config.tokens       = { "token" => "tokensecret" }
      config.max_drift    = 30
      config.replay_protector = lambda { |oauth|
                                  @store ||= Set.new
                                  return true if @store.include?(oauth)
                                  @store << oauth
                                  false
                                }
    end

    Sworn::Middleware.new dummy_app
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
    expect(last_response.status).to eq 400
  end

  it "returns 401 when signature is invalid" do
    get "/", {}, { 'HTTP_AUTHORIZATION' => 'OAuth oauth_consumer_key="invalid", oauth_token="", oauth_nonce="abc", oauth_timestamp="123", oauth_signature_method="HMAC-SHA1", oauth_version="1.0", oauth_signature="nowayjose"' }
    expect(last_response.status).to eq 401
  end

  it "returns 401 when signature timestamp is out of bounds" do
    get "/", {}, { 'HTTP_AUTHORIZATION' => oauth_signature(:timestamp => (Time.now.to_i - 60).to_s) }
    expect(last_response.status).to eq 401
  end

  it "returns 401 when signature is replayed" do
    replayed = oauth_signature
    get "/", {}, { 'HTTP_AUTHORIZATION' => replayed }
    expect(last_response.status).to eq 200
    get "/", {}, { 'HTTP_AUTHORIZATION' => replayed }
    expect(last_response.status).to eq 401
  end

  it "returns 200 for valid consumer-only signature" do
    get "/", {}, { 'HTTP_AUTHORIZATION' => oauth_signature }
    expect(last_response.status).to eq 200
  end

  it "returns 200 for valid consumer + access token signature" do
    get "/", {}, { 'HTTP_AUTHORIZATION' => oauth_signature(:token => "token", :token_secret => "tokensecret") }
    expect(last_response.status).to eq 200
  end
end
