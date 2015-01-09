require "spec_helper"

describe RubyNos::UDPReceptor do

  subject{UDPReceptor.new(port)}

  describe "#receive" do
    let(:socket_tx) {UDPSocket.open}
    let(:message) {"Example message"}
    let(:host)    {"224.0.0.1"}
    let(:port)    {3784}
    let(:agent)     {Agent.new(:uuid => "12345")}
    let(:processor) {Processor.new(agent)}

    after(:each) do
      subject.socket.close
      socket_tx.close
    end

    it "receives messages listening to multicast address" do
      subject.listen(processor)
      sleep 0.1
      expect(processor).to receive(:process_message).twice
      socket_tx.setsockopt(:IPPROTO_IP, :IP_MULTICAST_TTL, 1)
      socket_tx.send(message, 0, host, port)
      socket_tx.send(message, 0, host, port)
      sleep 0.1
    end
  end
end