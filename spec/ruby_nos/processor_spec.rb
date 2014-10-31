require "spec_helper"

describe RubyNos::Processor do
  subject{Processor.new}
  let(:query) {double("query", :where => agent)}
  let(:agent) {Agent.new(:uuid => "12345")}
  let(:message){Message.new({from: "ag:45678", to: "ag:12345", type: "PIN"}).serialize_message}
  let(:json_message) {JSON.generate(message)}
  let(:udp_socket) {double("UDPSocket", :receptor_address => [12345, "localhost"])}

  before(:each) do
    subject.agent = agent
    agent.udp_socket = udp_socket
  end

  describe "#process_message" do
    it "dispatch the message to the agents depending on the type" do
      expect(agent).to receive(:send_message).with({:type => "PON", :to => message[:fr]})
      subject.process_message(json_message)
    end
  end
end