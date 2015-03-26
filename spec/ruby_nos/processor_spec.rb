require "spec_helper"
require "json"

describe RubyNos::Processor do
  subject{Processor.new(agent)}
  let(:agent)                       {Agent.new(:uuid => agent_uuid, pending_response_list: pending_response_list)}
  let(:pending_response_list)       {ResponsePendingList.new}
  let(:json_message)                {message.to_json}
  let(:udp_socket)                  {double("UDPSocket", :receptor_address => [12345, "localhost"])}
  let(:cloud)                       {double("Cloud", :agent_list => [agent.uuid], :uuid => cloud_uuid)}
  let(:agent_uuid)                  {SecureRandom.uuid}
  let(:cloud_uuid)                  {SecureRandom.uuid}
  let(:received_agent_uuid)         {agent_uuid.gsub("-", "")}
  let(:another_agent_uuid)          {SecureRandom.uuid}
  let(:another_agent_uuid_received) {another_agent_uuid.gsub("-", "")}
  let(:received_cloud_uuid)         {cloud_uuid.gsub("-", "")}

  before(:each) do
    agent.udp_rx = udp_socket
    agent.cloud = cloud
  end

  describe "#process_message" do
    context "PING message arrives" do
      let(:message){Message.new({from: "AGT:#{another_agent_uuid_received}", to: "AGT:#{received_agent_uuid}", type: "PIN", sequence_number: 123456}).serialize_message}
      it "it sends a PON and increments the sequence number" do
        expect(agent).to receive(:send_message).with({:type => "PON", sequence_number: 123457})
        subject.process_message(json_message)
      end
    end

    context "PONG messages arrives" do
      let(:message){Message.new({from: "AGT:#{another_agent_uuid_received}", to: "CLD:#{received_cloud_uuid}", type: "PON", sequence_number: 1234}).serialize_message}
      it "it updates the cloud list" do
        expect(cloud).to receive(:update).with(another_agent_uuid, nil)
        subject.process_message(json_message)
      end

      it "checks if the message already exists on the pending response list" do
        expect(pending_response_list).to receive(:is_on_the_list?).with(another_agent_uuid)
        expect(cloud).to receive(:update).with(another_agent_uuid, nil)
        subject.process_message(json_message)
      end
    end

    context "Discovery message arrives" do
      let(:message){Message.new({from: "AGT:#{another_agent_uuid_received}", to: "CLD:#{received_cloud_uuid}", type: "DSC", sequence_number: 123456}).serialize_message}
      it "it updates the cloud if the user is not on the list and sends a PRS and increments the sequence number" do
        expect(cloud).to receive(:is_on_the_list?).with(another_agent_uuid)
        expect(cloud).to receive(:update).with(another_agent_uuid, nil)
        expect(agent).to receive(:send_message).with({:type => "PRS", sequence_number: 123457})
        subject.process_message(json_message)
      end
    end

    context "#Presence message arrives" do
      let(:message) {Message.new({type: "PRS", from:"AGT:#{another_agent_uuid_received}", to: "CLD:#{received_cloud_uuid}", data: {:ap => "example_app"}}).serialize_with_optional_fields({:options => [:dt]})}
      it "store the information of the agent and update the list" do
        expect(cloud).to receive(:update).with(another_agent_uuid, {:ap => "example_app"})
        subject.process_message(json_message)
      end
    end
  end
end