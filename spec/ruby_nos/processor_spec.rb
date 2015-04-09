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
  let(:sequence_number)             {12345}

  before(:each) do
    agent.udp_rx = udp_socket
    agent.cloud = cloud
  end

  describe "#process_message" do
    let(:message){Message.new({from: "AGT:#{another_agent_uuid_received}", to: "AGT:#{received_agent_uuid}", type: "PIN", sequence_number: sequence_number}).serialize_message}
    it "checks the signature of the messages" do
      expect_any_instance_of(SignatureGenerator).to receive(:valid_signature?)
      subject.process_message(json_message)
    end

    context "PING message arrives" do
      let(:message){Message.new({from: "AGT:#{another_agent_uuid_received}", to: "AGT:#{received_agent_uuid}", type: "PIN", sequence_number: sequence_number}).serialize_message}
      it "it sends a PON and increments the sequence number" do
        expect(agent).to receive(:send_message).with({:type => "PON", sequence_number: sequence_number + 1})
        subject.process_message(json_message)
      end
    end

    context "PONG messages arrives" do
      let(:message){Message.new({from: "AGT:#{another_agent_uuid_received}", to: "CLD:#{received_cloud_uuid}", type: "PON", sequence_number: sequence_number}).serialize_message}
      it "it updates the cloud list" do
        expect(cloud).to receive(:update).with(another_agent_uuid, sequence_number, nil)
        subject.process_message(json_message)
      end
    end

    context "Discovery message arrives" do
      let(:message){Message.new({from: "AGT:#{another_agent_uuid_received}", to: "CLD:#{received_cloud_uuid}", type: "DSC", sequence_number: sequence_number}).serialize_message}
      it "it updates the cloud if the user is not on the list and sends a PRS and increments the sequence number" do
        expect(cloud).to receive(:is_on_the_list?).with(another_agent_uuid)
        expect(cloud).to receive(:update).with(another_agent_uuid, sequence_number, nil)
        expect(agent).to receive(:send_message).with({:type => "PRS", sequence_number: sequence_number + 1})
        subject.process_message(json_message)
      end
    end

    context "#Presence message arrives" do
      let(:message) {Message.new({type: "PRS", from:"AGT:#{another_agent_uuid_received}", to: "CLD:#{received_cloud_uuid}", sequence_number: sequence_number, data: {:ap => "example_app"}}).serialize_with_optional_fields({:options => [:dt]})}
      it "store the information of the agent and update the list" do
        expect(cloud).to receive(:update).with(another_agent_uuid, sequence_number, {:ap => "example_app"})
        subject.process_message(json_message)
      end
    end

    context "#Enquiry message arrives" do
      let(:message) {Message.new({type: "ENQ", from:"AGT:#{another_agent_uuid_received}", to: "CLD:#{received_cloud_uuid}", sequence_number: sequence_number}).serialize_message}
      it "returns a QNE message" do
        expect(agent).to receive(:send_message).with({:type => "QNE", sequence_number: sequence_number + 1})
        subject.process_message(json_message)
      end
    end

    context "#Answer to an enquiry message arrives" do
      let(:rest_api) {RestApi.new}
      let(:endpoint_params) {{path: "/example", type: "PUBLIC", port: 5000, host: "localhost"}}
      let(:message) {Message.new({type: "QNE", from:"AGT:#{another_agent_uuid_received}", to: "CLD:#{received_cloud_uuid}", sequence_number: sequence_number, data: rest_api.to_hash}).serialize_with_optional_fields({:options => [:dt]})}

      before(:each) do
        rest_api.add_endpoint(endpoint_params)
      end

      it "stores the information of the api in the remote agent" do
        expect(cloud).to receive(:is_on_the_list?).with(another_agent_uuid)
        expect(cloud).to receive(:insert_new_remote_agent).with(an_instance_of(RemoteAgent))
        subject.process_message(json_message)
      end
    end
  end
end