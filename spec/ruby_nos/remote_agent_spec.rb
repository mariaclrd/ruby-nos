require "spec_helper"

describe "#RubyNos::RemoteAgent" do
  subject{RemoteAgent.new({timestamp: 1, endpoints:[Endpoint.new({type: "UDP"})], rest_api: RestApi.new})}
  let(:another_agent){RemoteAgent.new({timestamp: 2, endpoints: [Endpoint.new({type: "HTTP"})], rest_api: RestApi.new})}

  before(:each) do
    subject.rest_api.add_endpoint({type: "PUBLIC"})
    another_agent.rest_api.add_endpoint({type: "HEALTHCHECK"})
  end

  describe "#add_endpoint" do
    it "adds and endpoint to the list of endpoints for the remote agent" do
      subject.add_endpoint({type: "UDP"})
      expect(subject.endpoints.count).to eq(2)
    end
  end

  describe "#endpoints collection" do
    it "shows the endpoints as an array of hashes" do
      subject.add_endpoint({type: "UDP"})
      expect(subject.endpoints_collection.first.keys).to eq([:pa, :po, :st, :ty, :xp, :host])
    end
  end

  describe "#same_timestamp?" do
    it "compares the timestamp with another agent" do
      expect(subject.same_timestamp?(subject)).to eq(true)
      expect(subject.same_timestamp?(another_agent)).to eq(false)
    end
  end

  describe "#same_endpoints?" do
    it "compares the timestamp with another agent" do
      expect(subject.same_endpoints?(subject)).to eq(true)
      expect(subject.same_endpoints?(another_agent)).to eq(false)
    end
  end

  describe "#same_api?" do
    it "compares the timestamp with another agent" do
      expect(subject.same_api?(subject)).to eq(true)
      expect(subject.same_api?(another_agent)).to eq(false)
    end
  end
end