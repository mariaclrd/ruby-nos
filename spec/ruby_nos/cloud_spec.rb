require "spec_helper"

describe "#RubyNos::Cloud" do
  subject{Cloud.new(uuid:cloud_uuid)}
  let(:cloud_uuid) {"122445"}
  let(:agent_uuid) {"12345"}
  let(:info)       {{"endpoints" => ["something,something,something"]}}
  let(:info_stored){ {:endpoints => [{:type => "something", :port => "something", :address => "something"}]}}

  describe "#update" do

    describe "new agent" do
      it "stores agents information if it is new" do
        subject.update(agent_uuid, info)
        expect(subject.agents_info).to eq([{agent_uuid => info_stored}])
      end
    end

    describe "old agent" do
      let(:new_info) {{"endpoints" => ["another_thing,something,something"]}}
      let(:new_info_stored){ {:endpoints => [{:type => "another_thing", :port => "something", :address => "something"}]}}

      before(:each) do
        subject.update(agent_uuid, info)
      end

      it "if the agent exists and the information is not the same it updates to this new information" do
        subject.update(agent_uuid, new_info)
        expect(subject.agents_info).to eq([{agent_uuid => new_info_stored}])
      end
    end
  end

  describe "#find_info_for_agent_uuid" do
    it "finds the agent for its uuid" do
      subject.update(agent_uuid, info)
      expect(subject.find_info_for_agent_uuid("12345")).to eq(info_stored)
    end
  end

  describe "#is_on_the_list?" do
    it "says if an agent is on our local list or not" do
      subject.update(agent_uuid, info)
      expect(subject.is_on_the_list?(agent_uuid)).to eq(true)
    end
  end

  describe "#list_of_agents" do
    it "returns the list of agents present on the cloud" do
      subject.update(agent_uuid, info)
      expect(subject.list_of_agents).to eq([agent_uuid])
    end
  end

  describe "#delete_from_cloud" do
    it "eliminates the agent from cloud list" do
      subject.update(agent_uuid, info)
      subject.delete_from_cloud(agent_uuid)
      expect(subject.agents_info).to eq([])
    end
  end
end
