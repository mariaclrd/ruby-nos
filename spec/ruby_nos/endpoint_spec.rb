require "spec_helper"

describe "#RubyNos::Endpoint" do
  subject{Endpoint.new}

  describe "type=" do
    it "can does not allow types that are not on the allowed types list" do
      expect{subject.type = "SOMETHING"}.to raise_error(SyntaxError)
    end

    it "allows to set a type that is on the list" do
      subject.type = "PUBLIC"
      expect(subject.type).to eq("PUBLIC")
    end
  end

  describe "#to_hash" do
    it "returns the attributes of the endpoint in a hash" do
      subject.path = "/example_path"
      expect(subject.to_hash.keys).to eq([:pa, :po, :st, :ty, :xp, :ho])
      expect(subject.to_hash[:pa]).to eq("/example_path")
    end
  end

  describe "#aliasing" do
    let(:endpoint_hash) {{pa: "/api/", po: 1234, st: 0, ty: "PUB", xp: 0, ho: "localhost"}}

    it "allows to instantiate an endpoint object attributes with the correct values" do
      endpoint = Endpoint.new(endpoint_hash)
      expect(endpoint.port).to eq 1234
      expect(endpoint.path).to eq "/api/"
      expect(endpoint.sticky).to eq 0
      expect(endpoint.type).to eq "PUB"
      expect(endpoint.priority).to eq 0
      expect(endpoint.host).to eq "localhost"
    end
  end
end