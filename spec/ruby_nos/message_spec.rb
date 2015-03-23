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
      expect(subject.serialize_message.keys).to include(:v, :fr, :to, :ty, :hp)
    end

    it "generates a sequence number if it is not specified" do
      expect(subject.serialize_message[:sq]).to eq(Time.now.to_i)
    end
  end

  describe "#serialize_with_optional_fields" do
    it "returns the serialized message" do
      expect(subject.serialize_with_optional_fields({:options => [:rx, :dt]}).keys).to include(:v, :fr, :to, :ty, :hp, :rx, :dt)
    end
  end
end