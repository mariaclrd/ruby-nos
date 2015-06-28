require "spec_helper"

describe RubyNos::UDPReceptor do

  subject{UDPReceptor.new}

  describe "#receive" do
    let(:socket_tx) {UDPSocket.open}
    let(:message)   {"Example message"}
    let(:host)      {"230.31.32.33"}
    let(:port)      {3784}
    let(:processor) {double("processor")}

    before(:each) do
      socket_tx.setsockopt(:IPPROTO_IP, :IP_MULTICAST_TTL, 1)
    end

    after(:each) do
      subject.socket.close
      socket_tx.close
    end

    it "receives messages listening to multicast address" do
      allow(processor).to receive(:process_message)
      expect(processor).to receive(:process_message).and_raise("Boom")
      thread = subject.listen(processor)
      socket_tx.send(message, 0, host, port)
      expect{thread.join}.to raise_error("Boom")
    end
  end
end