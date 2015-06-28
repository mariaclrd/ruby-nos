require "spec_helper"

describe "#RubyNos::Formatter" do
  subject{Formatter.new}
  let(:uuid) {SecureRandom.uuid}

  describe "convert_to_uuid" do
    let(:string_uuid){uuid.gsub("-", "")}
    it "converts an string into uuid format" do
       expect(subject.convert_to_uuid(string_uuid)).to eq uuid
    end
  end

  describe "#uuid_format?" do
    it "returns true if the parameter match the uuid format" do
      expect(subject.uuid_format?(uuid)).to eq(true)
    end
  end

  describe "#uuid_to_string" do
    it "converts an uuid to string" do
      result = subject.uuid_to_string(uuid)
      expect(result.include?("-")).to eq(false)
      expect(uuid.split("").count - result.split("").count).to eq 4
    end
  end

  describe "#parse_message" do
    let(:message) {{:a => "something"}}
    it "returns the message as a hash format if it was a hash " do
      expect(subject.parse_message(message.to_json)).to eq(message)
    end
  end
end