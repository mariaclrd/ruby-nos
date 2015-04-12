require "spec_helper"

describe "#RubyNos::Cloud" do
  subject{Cloud.new(uuid:cloud_uuid)}
  let(:cloud_uuid) {"122445"}
  let(:agent_uuid) {"12345"}
  let(:sequence_number) {1}
  let(:agent_info) {{agent_uuid: agent_uuid, sequence_number: sequence_number, info: info}}
  let(:info)       {{:endpoints => ["UDP,something,something"]}}
  let(:info_stored) {RemoteAgent.new({uuid: agent_uuid, endpoints: [endpoint], sequence_number: sequence_number})}
  let(:endpoint)   { Endpoint.new({:type => "UDP", :port => "something", :host => "something"})}

  describe "#update" do

    describe "new agent" do
      it "stores agents information if it is new" do
        subject.update(agent_info)
        expect(subject.agents_info.count).to eq(1)
        expect(subject.agents_info.first.keys).to eq([agent_uuid])
      end
    end

    describe "old agent" do
      let(:new_info) {{:endpoints => ["UDP,another_something,something"]}}
      let(:new_sequence_number) {2}
      let(:new_endpoint) {Endpoint.new({:type => "UDP", :port => "another_something", :host => "something"})}
      let(:new_info_stored) {RemoteAgent.new({uuid: agent_uuid, endpoints: [new_endpoint], sequence_number: sequence_number})}

      before(:each) do
        subject.update(agent_info)
      end

      it "if the agent exists and the information is not the same it updates to this new information" do
        subject.update({agent_uuid: agent_uuid, sequence_number: new_sequence_number, info: new_info})
        expect(subject.agents_info.count).to eq(1)
        expect(subject.agents_info.first[agent_uuid].endpoints.first.port).to eq("another_something")
      end

      it "it does not update the info the sequence number is lower or equal than the previous one stored" do
        another_info = {:endpoints => ["UDP,more_things,something"]}
        subject.update({agent_uuid: agent_uuid, sequence_number: sequence_number, info: another_info})
        expect(subject.agents_info.count).to eq(1)
        expect(subject.agents_info.first[agent_uuid].endpoints.first.port).to eq("something")
      end

      it "updates an agent if the timestamp has changed" do
        allow(subject).to receive(:correct_timestamp?).and_return(true)
        subject.update({agent_uuid: agent_uuid, sequence_number: new_sequence_number, timestamp: "something"})
        expect(subject.agents_info.count).to eq(1)
        expect(subject.agents_info.first[agent_uuid].timestamp).to eq("something")
      end

      it "not overwrite the information on the list with null information" do
        subject.update({agent_uuid: agent_uuid, sequence_number: new_sequence_number, info: {endpoints: nil}})
        expect(subject.agents_info.count).to eq(1)
        expect(subject.agents_info.first[agent_uuid].endpoints.first.port).to eq("something")
      end
    end
  end

  describe "#info_on_the_list" do
    it "finds the agent for its uuid" do
      subject.update(agent_info)
      expect(subject.info_on_the_list("12345").endpoints.first.port).to eq("something")
    end
  end

  describe "#is_on_the_list?" do
    it "says if an agent is on our local list or not" do
      subject.update(agent_info)
      expect(subject.is_on_the_list?(agent_uuid)).to eq(true)
    end
  end

  describe "#list_of_agents" do
    it "returns the list of agents present on the cloud" do
      subject.update(agent_info)
      expect(subject.list_of_agents).to eq([agent_uuid])
    end
  end

  describe "#delete_from_cloud" do
    it "eliminates the agent from cloud list" do
      subject.update(agent_info)
      subject.eliminate_from_list(agent_uuid)
      expect(subject.agents_info).to eq([])
    end
  end
end
