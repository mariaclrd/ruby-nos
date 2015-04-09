require "spec_helper"

describe "#RubyNos::RemoteAgent" do
  subject{RemoteAgent.new}

  describe "#add_endpoint" do
    it "adds and endpoint to the list of endpoints for the remote agent" do
      subject.add_endpoint({type: "UDP"})
      expect(subject.endpoints.count).to eq(1)
    end
  end
end