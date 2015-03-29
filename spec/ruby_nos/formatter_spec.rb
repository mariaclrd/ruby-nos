require "spec_helper"

describe "#RubyNos::Formatter" do
  subject{Formatter.new}
  let(:uuid) {SecureRandom.uuid}

  describe "convert_to_uuid" do
    let(:string_uuid){uuid.gsub("-", "")}
    it "converts an string into uuid format" do
       expect(subject.convert_to_uuid(string_uuid)).to match(/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/)
    end
  end

  describe "#uuid_format?" do
    it "returns true if the parameter match the uuid format" do
      expect(subject.uuid_format?(uuid)).to eq(true)
    end
  end

  describe "#uuid_to_string" do
    it "converts an uuid to string" do
      expect(subject.uuid_to_string(uuid)["-"]).to eq(nil)
    end
  end
end