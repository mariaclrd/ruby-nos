require "spec_helper"

describe "#RubyNos::RestApi" do
  subject{RestApi.new}

  describe "#add_endpoint" do
    it "creates a new Endpoint and add it to the list of endpoints" do
      subject.add_endpoint(path: "/this_path", type: "PUBLIC", port: 3000)
      expect(subject.endpoints.count).to eq(1)
    end
  end

  describe "#to_hash" do
    it "returns the name of the microservices and the list of endpoints on a hash" do
      expect(subject.to_hash.keys).to eq([:name, :apis])
    end

    it "returns the list of endpoints in an array" do
      subject.add_endpoint(path: "/this_path", type: "PUBLIC", port: 3000)
      expect(subject.to_hash[:apis].first[:path]).to eq("/this_path")
    end
  end
end