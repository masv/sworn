require 'spec_helper'

describe Sworn::ReplayProtector::Memory do
  let(:memory) { Sworn::ReplayProtector::Memory.new }
  describe "#replayed?" do
    it "returns false for fresh tokens" do
      expect(memory.replayed?("signature")).to be_false
    end

    it "returns true for replayed tokens" do
      memory.replayed?("signature")
      expect(memory.replayed?("signature")).to be_true
    end
  end
end
