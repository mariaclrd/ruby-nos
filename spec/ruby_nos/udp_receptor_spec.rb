require "spec_helper"

describe RubyNos::UDPReceptor do

  subject{UDPReceptor.new}

  describe "#receive" do
    let(:socket_tx) {UDPSocket.open}
    let(:message) {"Example message"}
    let(:host)    {"224.0.0.1"}
    let(:port)    {3783}
    let(:processor) {Processor.new}

    after(:each) do
      subject.socket.close
      socket_tx.close
    end

    it "receives a message listening to multicast address" do
      subject.listen(processor)
      socket_tx.setsockopt(:IPPROTO_IP, :IP_MULTICAST_TTL, 1)
      socket_tx.send(message, 0, host, port)
      wait_for{sleep 1; processor.to_receive(:process_message)}
    end
  end
end