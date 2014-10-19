require "spec_helper"

describe RubyNos::UDPSender do

  subject{UDPSender.new}
  let(:host)    {"127.0.0.1"}
  let(:message) {"message"}

  describe "#initialize" do
    after(:each) do
      subject.socket.close
    end

    it "opens a new UDP socket" do
      subject.socket.send(message, 0, host, subject.port)
      expect( subject.socket.recvfrom(16).first).to eq(message)
    end
  end

  describe "#send" do

    after(:each) do
      subject.socket.close
    end

    it "sends a message to a specified socket" do
      message = "example message"
      subject.send({message:message, host:host, port:subject.port})
      expect(subject.socket.recvfrom(16).first). to eq(message)
    end
  end

  describe "#receive" do
    after(:each) do
      subject.socket.close
    end

    it "receives a message" do
      subject.send({message:message, host:host, port:subject.port})
      expect(subject.receive).to eq(message)
      expect(subject.receptor_address.last).to eq(host)
    end
  end
end