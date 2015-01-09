require "spec_helper"

describe "#RubyNos::Cloud" do
  subject{Cloud.new(uuid:cloud_uuid)}
  let(:cloud_uuid) {"122445"}

  describe "#add_agent" do
    let(:uuid) {"12345"}
    it "adds an agent to the agents_list" do
      subject.add_agent(uuid)
      expect(subject.agents_list.count).to eq(1)
    end
  end

  describe "#store_info" do
    let(:message) {Message.new({type: "PRS", data: {ap:"example_app"}}).serialize_with_optional_fields({:options => [:dt]})}
    it "store the information of the message" do
      subject.store_info(message)
      expect(subject.agents_info.count).to eq(1)
    end

    it "stores extra info if it is present" do
      subject.store_info(message)
      expect(subject.agents_info.first[:application]).to eq("example_app")
    end
  end

  describe "#find_for_app" do
    let(:message) {Message.new({type: "PRS", from:"ag:12345", data: {ap:"example_app"}}).serialize_with_optional_fields({:options => [:dt]})}
    it "finds the agent associated to a concrete application" do
      subject.store_info(message)
      expect(subject.find_for_app("example_app")[:agent_uuid]).to eq("ag:12345")
    end
  end

  describe "#find_for_agent_uuid" do
    let(:message) {Message.new({type: "PRS", from:"ag:12345", data: {ap:"example_app"}}).serialize_with_optional_fields({:options => [:dt]})}
    it "finds the agent for its uuid" do
      subject.store_info(message)
      expect(subject.find_for_agent_uuid("ag:12345")[:agent_uuid]).to eq("ag:12345")
    end
  end

  describe "#is_on_the_list?" do
    let(:uuid) {"12345"}
    it "says if an agent is on our local list or not" do
      subject.add_agent(uuid)
      expect(subject.is_on_the_list?(uuid)).to eq(true)
    end
  end
end
