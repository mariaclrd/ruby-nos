require "spec_helper"

describe "RubyNos::Messaage" do

  subject {Message.new}

  describe "create_message" do
    it "creates a message with all the specified fields" do
      subject.create_message(:from => "Alice", :to => "Bob")
      expect(subject.from).to eq("Alice")
      expect(subject.to).to eq("Bob")
    end
  end

  describe "#serialize_message" do
    it "returns the serialized message" do
      expect(subject.serialize_message.keys).to include(:uuid, :version, :from, :to, :from, :hops, :seq, :reliable, :data, :sig, :rnd)
    end
  end
end