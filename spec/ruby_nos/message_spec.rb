require "spec_helper"

describe "RubyNos::Message" do

  subject {Message.new(params)}
  let(:params) {{:from => "Alice", :to => "Bob"}}

  describe "create_message" do
    it "creates a message with all the specified fields" do
      expect(subject.from).to eq("Alice")
      expect(subject.to).to eq("Bob")
    end
  end

  describe "#serialize_message" do
    it "returns the serialized message" do
      expect(subject.serialize_message.keys).to include(:v, :fr, :to, :ty, :hp, :sg)
    end
  end

  describe "#serialize_with_optional_fields" do
    it "returns the serialized message" do
      expect(subject.serialize_with_optional_fields({:options => [:rx, :dt]}).keys).to include(:v, :fr, :to, :ty, :hp, :rx, :dt, :sg)
    end
  end

  describe "#calculate_digest" do
    let(:message_to_be_digested) do
      message = subject.serialize_message
      message.delete(:sg)
      message
    end

    it "use Digest::MD5 module" do
      expect(Digest::MD5).to receive(:digest).with("#{message_to_be_digested}")
      subject.calculate_digest
    end

    it "returns the calculated MD5 digest" do
      expect(subject.calculate_digest.length).to eq(16)
    end
  end
end