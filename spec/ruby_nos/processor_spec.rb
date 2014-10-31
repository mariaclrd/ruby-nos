require "spec_helper"

describe RubyNos::Processor do
  subject{Processor.new}
  let(:query)        {double("query", :where => agent)}
  let(:agent)        {Agent.new(:uuid => "12345")}
  let(:json_message) {JSON.generate(message)}
  let(:udp_socket)   {double("UDPSocket", :receptor_address => [12345, "localhost"])}
  let(:cloud)        {double("Cloud", :agent_list => [agent.uuid], :uuid => "12345")}

  before(:each) do
    subject.agent = agent
    agent.udp_socket = udp_socket
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
      let(:message){Message.new({from: "ag:45678", to: "cd:12345", type: "DSC"}).serialize_message}
      it "it sends a PRS" do
        expect(agent).to receive(:send_message).with({:type => "PRS"})
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
  end
end