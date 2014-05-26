require 'spec_helper'

class DummyRedis
  def initialize
    @store = Hash.new
  end

  def exists(key)
    @store.has_key?(key)
  end

  def setex(key, ttl, value)
    raise 'ttl mismatch' unless ttl == Sworn.configuration.max_drift
    @store[key] = [ttl, value]
  end
end

describe Sworn::ReplayProtector::Redis do
  let(:redis_protector) do
    Sworn::ReplayProtector::Redis.new(:redis_connection => DummyRedis.new)
  end

  let(:signature) do
    {
      :timestamp => 123,
      :nonce => "abc"
    }
  end

  describe "#replayed?" do
    it "returns false for fresh tokens" do
      expect(redis_protector.replayed?(signature)).to be_false
    end

    it "returns true for replayed tokens" do
      redis_protector.replayed?(signature)
      expect(redis_protector.replayed?(signature)).to be_true
    end
  end
end
