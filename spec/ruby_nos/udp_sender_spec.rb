require "spec_helper"

describe RubyNos::UDPSender do

  subject{UDPSender.new}
  let(:host)    {"127.0.0.1"}
  let(:port)    {3783}

  describe "#send" do
    let(:message) {"Example message"}

    context "multicast address by default" do
      let(:host)      {"224.0.0.1"}
      let(:bind_addr) {"0.0.0.0"}
      let(:port)       {3783}
      let(:socketrx)    {UDPSocket.new}

      before(:each) do
        membership = IPAddr.new(host).hton + IPAddr.new(bind_addr).hton
        socketrx.setsockopt(:IPPROTO_IP, :IP_ADD_MEMBERSHIP, membership)
        socketrx.setsockopt(:SOL_SOCKET, :SO_REUSEPORT, 1)
        socketrx.bind(bind_addr, port)
      end

      after(:each) do
        socketrx.close
      end

      it "sends to group address by default" do
        subject.send({message:message})
        expect(socketrx.recvfrom(16).first). to eq(message)
      end
    end
  end
end