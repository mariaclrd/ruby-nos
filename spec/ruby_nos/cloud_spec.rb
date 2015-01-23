require "spec_helper"

describe "#RubyNos::Cloud" do
  subject{Cloud.new(uuid:cloud_uuid)}
  let(:cloud_uuid) {"122445"}
  let(:agent_uuid) {"12345"}
  let(:info)       {{"endpoints" => "something"}}

  describe "#update" do

    describe "new agent" do
      it "stores agents information if it is new" do
        subject.update(agent_uuid, info)
        expect(subject.agents_info).to eq([{agent_uuid => info}])
      end
    end

    describe "old agent" do
      let(:new_info) {{"endpoints" => "another_thing"}}

      before(:each) do
        subject.update(agent_uuid, info)
      end

      it "if the agent exists and the information is not the same it updates to this new information" do
        subject.update(agent_uuid, new_info)
        expect(subject.agents_info).to eq([{agent_uuid => new_info}])
      end
    end
  end

  describe "#find_info_for_agent_uuid" do
    it "finds the agent for its uuid" do
      subject.update(agent_uuid, info)
      expect(subject.find_info_for_agent_uuid("12345")).to eq(info)
    end
  end

  describe "#is_on_the_list?" do
    it "says if an agent is on our local list or not" do
      subject.update(agent_uuid, info)
      expect(subject.is_on_the_list?(agent_uuid)).to eq(true)
    end
  end
end
