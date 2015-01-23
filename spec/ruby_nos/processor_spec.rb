require "spec_helper"
require "json"

describe RubyNos::Processor do
  subject{Processor.new(agent)}
  let(:query)        {double("query", :where => agent)}
  let(:agent)        {Agent.new(:uuid => "12345")}
  let(:json_message) {message.to_json}
  let(:udp_socket)   {double("UDPSocket", :receptor_address => [12345, "localhost"])}
  let(:cloud)        {double("Cloud", :agent_list => [agent.uuid], :uuid => "12345")}

  before(:each) do
    agent.udp_rx_socket = udp_socket
    agent.cloud = cloud
  end

  describe "#process_message" do
    context "PING message arrives" do
      let(:message){Message.new({from: "ag:45678", to: "ag:12345", type: "PIN", sequence_number: 123456}).serialize_message}
      it "it sends a PON and increments the sequence number" do
        expect(agent).to receive(:send_message).with({:type => "PON", sequence_number: 123457})
        subject.process_message(json_message)
      end
    end

    context "PONG messages arrives" do
      let(:message){Message.new({from: "ag:45678", to: "cd:12345", type: "PON", sequence_number: 1234}).serialize_message}
      it "it updates the cloud list" do
        expect(cloud).to receive(:update).with("45678", nil)
        subject.process_message(json_message)
      end
    end

    context "Discovery message arrives" do
      let(:message){Message.new({from: "ag:45678", to: "cd:12345", type: "DSC", sequence_number: 123456}).serialize_message}
      it "it sends a PRS and increments the sequence number" do
        expect(agent).to receive(:send_message).with({:type => "PRS", sequence_number: 123457})
        subject.process_message(json_message)
      end
    end

    context "#Presence message arrives" do
      let(:message) {Message.new({type: "PRS", from:"ag:12345", to: "cd:12345", data: {:ap => "example_app"}}).serialize_with_optional_fields({:options => [:dt]})}
      it "store the information of the agent and update the list" do
        expect(cloud).to receive(:update).with("12345", {:ap => "example_app"})
        subject.process_message(json_message)
      end
    end
  end
end