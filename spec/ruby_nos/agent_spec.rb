require "spec_helper"

describe "#RubyNos::Agent" do
  subject{Agent.new(cloud_uuid: "2142142")}
  let(:cloud_uuid) {"2142142"}

  describe "#configure" do
    it "initialize the UDPReceptor" do
      expect(subject.udp_rx_socket).to receive(:listen).and_return(an_instance_of(Thread))
      subject.configure
    end

    it "joins the cloud" do
      expect(subject).to receive(:send_message).with({type: "DSC"})
      subject.configure
    end
  end

  describe "#send_message" do
    let(:cloud) {double("Cloud", :uuid => cloud_uuid)}
    let(:message){double("Message", :serialize_message => "SerializedMessage")}
    let(:udp_socket){double("UDPSocket")}
    let(:host) {"127.0.0.1"}
    let(:port) {"6700"}

    it "sends a message using the UDP Socket" do
      subject.cloud = cloud
      expect(Message).to receive(:new).with({:from => "ag:#{subject.uuid}", :to => "cd:#{cloud.uuid}", :type => "DSC"}).and_return(message)
      expect_any_instance_of(UDPSender).to receive(:send).with({host: host, port: port, :message => "SerializedMessage"})
      subject.send_message({:type => "DSC", :port => port, :host => host})
    end
  end
end