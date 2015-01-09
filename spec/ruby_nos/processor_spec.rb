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
      let(:message){Message.new({from: "ag:45678", to: "ag:12345", type: "PIN"}).serialize_message}
      it "it sends a PON" do
        expect(agent).to receive(:send_message).with({:type => "PON"})
        subject.process_message(json_message)
      end
    end

    context "PONG messages arrives" do
      let(:message){Message.new({from: "ag:45678", to: "cd:12345", type: "PON"}).serialize_message}
      it "it updates the cloud list" do
        expect(cloud).to receive(:is_on_the_list?).with("45678")
        expect(cloud).to receive(:add_agent).with("45678")
        subject.process_message(json_message)
      end
    end

    context "Discovery message arrives" do
      let(:message){Message.new({from: "ag:45678", to: "cd:12345", type: "DSC"}).serialize_message}
      it "it sends a PRS" do
        expect(agent).to receive(:send_message).with({:type => "PRS"})
        subject.process_message(json_message)
      end
    end

    context "#ACK message arrives" do
      let(:message_without_digest){Message.new({from: "ag:45678", to: "cd:12345", type: "ACK"})}
      let(:digest){{sh: message_without_digest.calculate_digest, lg: 'MD5'}}
      let(:message){Message.new({from: "ag:45678", to: "cd:12345", type: "ACK", data: digest}).serialize_with_optional_fields({:options => [:dt]})}
      it "check the digest and if the result is correct it returns true" do
        expect(subject.process_message(json_message)).to eq(true)
      end
    end

    context "#Presence message arrives" do
      let(:message) {Message.new({type: "PRS", from:"ag:12345", to: "cd:12345", data: {:ap => "example_app"}}).serialize_with_optional_fields({:options => [:dt]})}
      it "store the information of the agent and update the list" do
        expect(cloud).to receive(:is_on_the_list?).with("12345")
        expect(cloud).to receive(:add_agent).with("12345")
        expect(cloud).to receive(:store_info).with(message)
        subject.process_message(json_message)
      end
    end
  end
end