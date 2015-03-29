require "spec_helper"

describe "RubyNos#SignGenerator" do
  subject{SignatureGenerator.new}
  let(:message) {"Example message"}

  before do
    subject.key = "key"
  end

  describe "#generate_signature" do
    it "generates a signature for a message" do
       expect(subject.generate_signature(message).size).to eq(40)
    end
  end

  describe "#check_signature" do
    it "returns true if the signature is correct" do
      digest = OpenSSL::Digest.new('sha1')
      signature = OpenSSL::HMAC.hexdigest(digest, subject.key, message)
      expect(subject.check_signature(message, signature)).to eq(true)
    end

    it "returns false if the signature is incorrect" do
      expect(subject.check_signature(message, "example")).to eq(false)
    end
  end
end