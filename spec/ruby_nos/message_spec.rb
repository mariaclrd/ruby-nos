require "spec_helper"

describe "RubyNos::Message" do

  describe "create_message" do
    let(:params) {{:from => "Alice", :to => "Bob"}}
    let(:message) {Message.new(params)}
    it "creates a message with all the specified fields" do
      expect(message.from).to eq("Alice")
      expect(message.to).to eq("Bob")
    end
  end

  describe "#serialize" do
    let(:message) {Message.new}
    it "returns the serialized message with the keys that have a value" do
      expect(message.serialize.keys).to eq([:v, :hp, :ts, :sq, :rx, :sg])
    end

    it "generates a sequence number if it is not specified" do
      expect(message.serialize[:sq]).to eq(Time.now.to_i)
    end

    it "adds a signature to each message" do
      expect_any_instance_of(SignatureGenerator).to receive(:generate_signature)
      message.serialize
    end

    context "with all the fields" do
      let(:params) {{:from => "Alice", :to => "Bob", :type => "PRS", :data => {a: "something"}}}
      let(:message) {Message.new(params)}

      it "returns the serialized message with all the keys" do
        expect(message.serialize.keys).to eq([:v, :ty, :fr, :to, :hp, :ts, :sq, :rx, :dt, :sg])
      end
    end
  end
end