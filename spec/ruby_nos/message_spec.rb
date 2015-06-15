require "spec_helper"

describe "RubyNos::Message" do

  describe "create_message" do
    let(:params) {{:from => "Alice", :to => "Bob"}}
    let(:message) {Message.new(params)}
    it "creates a message with all the specified fields" do
      expect(message.from).to eq("Alice")
      expect(message.to).to eq("Bob")
    end

    context "using the keys of the message" do
      let(:message) {Message.new(v: "1.0", fr: "someone")}
      it "allows to put the value in the correct attribute" do
        expect(message.version).to eq("1.0")
        expect(message.from).to eq("someone")
      end
    end
  end

  describe "#serialize" do
    let(:message) {Message.new}
    it "returns the serialized message with the keys that have a value" do
      expect(message.serialize.keys).to eq([:v, :hp, :ts, :rx, :sg])
    end

    it "adds a signature to each message" do
      expect_any_instance_of(SignatureGenerator).to receive(:generate_signature)
      message.serialize
    end

    context "with all the fields" do
      let(:params) {{:from => "Alice", :to => "Bob", :type => "PRS", :data => {a: "something"}}}
      let(:message) {Message.new(params)}

      it "returns the serialized message with all the keys" do
        expect(message.serialize.keys).to eq([:v, :ty, :fr, :to, :hp, :ts, :rx, :dt, :sg])
      end
    end
  end
end