require "spec_helper"
require "json"

describe RubyNos::Processor do
  subject{Processor.new(agent)}
  let(:agent)                       {Agent.new(:uuid => agent_uuid)}
  let(:json_message)                {message.to_json}
  let(:udp_socket)                  {double("UDPSocket", :receptor_address => [12345, "localhost"])}
  let(:cloud)                       {double("Cloud", :uuid => cloud_uuid, list: list)}
  let(:list)                        {double("list")}
  let(:agent_uuid)                  {SecureRandom.uuid}
  let(:cloud_uuid)                  {SecureRandom.uuid}
  let(:received_agent_uuid)         {agent_uuid.gsub("-", "")}
  let(:another_agent_uuid)          {SecureRandom.uuid}
  let(:another_agent_uuid_received) {another_agent_uuid.gsub("-", "")}
  let(:received_cloud_uuid)         {cloud_uuid.gsub("-", "")}
  let(:basic_message_to_agent)               {{from: "AGT:#{another_agent_uuid_received}", to: "AGT:#{received_agent_uuid}", timestamp: "something"}}
  let(:basic_message_to_cloud)               {{from: "AGT:#{another_agent_uuid_received}", to: "CLD:#{received_cloud_uuid}", timestamp: "something"}}
  let(:cloud_info) {{agent_uuid: another_agent_uuid, info: nil, timestamp: "something"}}

  before(:each) do
    allow_any_instance_of(UDPSender).to receive(:send).and_return(nil)
    agent.udp_rx = udp_socket
    agent.cloud = cloud
  end

  describe "#process_message" do
    let(:message){Message.new({type: "PIN"}.merge(basic_message_to_agent)).serialize}
    it "checks the signature of the messages" do
      expect_any_instance_of(SignatureGenerator).to receive(:valid_signature?)
      subject.process_message(json_message)
    end

    context "PING message arrives" do
      let(:message){Message.new({type: "PIN"}.merge(basic_message_to_agent)).serialize}
      it "it sends a PON" do
        expect(cloud).to receive(:update).with(cloud_info)
        expect(agent).to receive(:send_message).with({:type => "PON"})
        subject.process_message(json_message)
      end
    end

    context "PONG messages arrives" do
      let(:message){Message.new({type: "PON"}.merge(basic_message_to_cloud)).serialize}
      it "it updates the cloud list" do
        expect(cloud).to receive(:update).with(cloud_info)
        subject.process_message(json_message)
      end
    end

    context "Discovery message arrives" do
      let(:message){Message.new({type: "DSC"}.merge(basic_message_to_cloud)).serialize}
      it "it updates the cloud if the user is not on the list and sends a PRS" do
        expect(list).to receive(:is_on_the_list?).with(another_agent_uuid)
        expect(cloud).to receive(:update).with(cloud_info)
        expect(agent).to receive(:send_message).with({:type => "PRS"})
        subject.process_message(json_message)
      end
    end

    context "#Presence message arrives" do
      let(:message) {Message.new({type: "PRS", data: {:ap => "example_app"}}.merge(basic_message_to_cloud)).serialize}
      let(:cloud_info_with_endpoints) {{agent_uuid: another_agent_uuid, info: {:ap => "example_app"}, timestamp: "something"}}
      it "store the information of the agent and update the list" do
        expect(cloud).to receive(:update).with(cloud_info_with_endpoints)
        subject.process_message(json_message)
      end

      context "#present equals false" do
        let(:message) {Message.new({type: "PRS", data: {:ap => "example_app", :present => 0}}.merge(basic_message_to_cloud)).serialize}
        it "eliminates the agent from the cloud if present field is equal to false" do
          expect(list).to receive(:eliminate).with(another_agent_uuid)
          subject.process_message(json_message)
        end
      end
    end

    context "#Enquiry message arrives" do
      let(:message) {Message.new({type: "ENQ"}.merge(basic_message_to_cloud)).serialize}
      it "returns a QNE message" do
        expect(cloud).to receive(:update).with(cloud_info)
        expect(agent).to receive(:send_message).with({:type => "QNE"})
        subject.process_message(json_message)
      end
    end

    context "#Answer to an enquiry message arrives" do
      let(:rest_api) {RestApi.new}
      let(:endpoint_params) {{path: "/example", type: "PUBLIC", port: 5000, host: "localhost"}}
      let(:message) {Message.new({type: "QNE", data: rest_api.to_hash}.merge(basic_message_to_cloud)).serialize}
      let(:remote_agent) {double("remote_agent")}

      before(:each) do
        rest_api.add_endpoint(endpoint_params)
      end

      it "stores the information of the api in the remote agent" do
        expect(RemoteAgent).to receive(:new).with(uuid: another_agent_uuid, timestamp: "something", rest_api: an_instance_of(RestApi)).and_return(remote_agent)
        expect(cloud).to receive(:update).with(remote_agent)
        subject.process_message(json_message)
      end
    end
  end
end