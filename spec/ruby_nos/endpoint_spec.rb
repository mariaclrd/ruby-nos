require "spec_helper"

describe "#RubyNos::Endpoint" do
  subject{Endpoint.new}

  describe "type=" do
    it "can does not allow types that are not on the allowed types list" do
      begin
        subject.type = "SOMETHING"
      rescue Exception => e
      end
      expect(e.message).to eq("SyntaxError")
    end

    it "allows to set a type that is on the list" do
      subject.type = "PUBLIC"
      expect(subject.type).to eq("PUBLIC")
    end
  end

  describe "#to_hash" do
    it "returns the attributes of the endpoint in a hash" do
      subject.path = "/example_path"
      expect(subject.to_hash.keys).to eq([:path, :port, :sticky, :type, :priority, :host])
      expect(subject.to_hash[:path]).to eq("/example_path")
    end
  end
end