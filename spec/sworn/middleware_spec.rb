require 'spec_helper'
require 'rack/test'

describe Sworn::Middleware do
  include Rack::Test::Methods

  def dummy_app
    lambda { |_| [200, {}, "Hello"] }
  end

  def app
    Sworn::Middleware.new dummy_app, :consumers => { "consumer" => "consumersecret" }
  end

  it "returns 400 when signature is missing" do
    get "/"
    last_response.status.must_equal 400
  end

  it "returns 401 when signature is invalid" do
    get "/", {}, { 'HTTP_AUTHORIZATION' => 'OAuth oauth_consumer_key="invalid", oauth_token="", oauth_nonce="abc", oauth_timestamp="123", oauth_signature_method="HMAC-SHA1", oauth_version="1.0", oauth_signature="nowayjose"' }
    last_response.status.must_equal 401
  end

  it "returns 200 when signature is valid" do
    get "/", {}, { 'HTTP_AUTHORIZATION' => 'OAuth oauth_consumer_key="consumer", oauth_token="", oauth_nonce="5633141c5b", oauth_timestamp="1395680768", oauth_signature_method="HMAC-SHA1", oauth_version="1.0", oauth_signature="laa5+2VWj6vj7j/7+Gf4f2Pf2zc="' }
    last_response.status.must_equal 200
  end
end
