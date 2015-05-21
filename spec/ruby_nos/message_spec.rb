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
      expect(subject.serialize_message.keys).to eq([:v, :ty, :fr, :to, :hp, :rx, :ts, :sq, :sg])
    end

    it "generates a sequence number if it is not specified" do
      expect(subject.serialize_message[:sq]).to eq(Time.now.to_i)
    end

    it "adds a signature to each message" do
      expect_any_instance_of(SignatureGenerator).to receive(:generate_signature)
      subject.serialize_message
    end
  end

  describe "#serialize_with_optional_fields" do
    it "returns the serialized message" do
      expect(subject.serialize_message({:options => [:rx, :dt]}).keys).to eq([:v, :ty, :fr, :to, :hp, :rx, :ts, :sq, :dt, :sg])
    end

    it "adds a signature to each message" do
      expect_any_instance_of(SignatureGenerator).to receive(:generate_signature)
      subject.serialize_message({:options => [:rx, :dt]})
    end
  end
end