require "spec_helper"

describe "#RubyNos::Agent" do
  subject{Agent.new}
  let(:cloud_uuid) {"00000000-0000-006f-0000-0000000000de"}
  let(:cloud_uuid_in_message) {"000000000000006f00000000000000de"}

  describe "#configure" do
    let(:cloud) {Cloud.new(uuid: cloud_uuid)}
    let(:agent_uuid) {"12345"}

    before(:each) do
      subject.cloud = cloud
    end

    it "initialize the UDPReceptor" do
      expect(subject.udp_rx).to receive(:listen).and_return(an_instance_of(Thread))
      subject.configure
    end

    it "joins the cloud" do
      expect(subject).to receive(:send_message).with({type: "PRS"})
      expect(subject).to receive(:send_message).with({type: "DSC"})
      expect(subject).to receive(:send_message).with({type: "ENQ"})
      subject.configure
    end

    it "sends_a_ping_message if there are other agents in the cloud" do
      cloud.update(agent_uuid)
      expect(subject).to receive(:send_message).with({type: "PRS"})
      expect(subject).to receive(:send_message).with({type: "DSC"})
      expect(subject).to receive(:send_message).with({type: "ENQ"})
      expect(subject).to receive(:send_message).with({type: "PIN", to: "AGT:12345"})
      subject.configure
      sleep 0.1
    end
  end

  describe "#send_message" do
    let(:cloud) {double("Cloud", :uuid => cloud_uuid)}
    let(:message){double("Message", :serialize_message => "SerializedMessage")}
    let(:udp_socket){UDPReceptor.new}
    let(:rest_api) {RestApi.new}
    let(:endpoint) {Endpoint.new(path: "this_path")}
    let(:well_formed_presence_message){Message.new({from: "AGT:#{subject.uuid.gsub("-", "")}", to: "CLD:#{subject.cloud.uuid.gsub("-", "")}", type: "PRS", sequence_number: 3, data: {present: 1, endpoints: ["UDP,#{udp_socket.socket.connect_address.ip_port},#{udp_socket.socket.connect_address.ip_address}"]}}).serialize_with_optional_fields({options: [:dt]})}
    let(:well_formed_qne_message){Message.new({from: "AGT:#{subject.uuid.gsub("-", "")}", to: "CLD:#{subject.cloud.uuid.gsub("-", "")}", type: "QNE", sequence_number: 3, timestamp: "sometime", data: rest_api.to_hash}).serialize_with_optional_fields({options: [:dt]})}
    let(:host) {"0.0.0.0"}
    let(:port) {"3784"}

    before(:each) do
      subject.cloud = cloud
      subject.rest_api = rest_api
    end

    it "sends a message using the UDP Socket" do
      expect(Message).to receive(:new).with({:from => "AGT:#{subject.uuid.gsub("-", "")}", :to => "CLD:#{cloud.uuid.gsub("-", "")}", :type => "DSC", :sequence_number => nil}).and_return(message)
      expect_any_instance_of(UDPSender).to receive(:send).with({host: host, port: port, :message => "SerializedMessage"})
      subject.send_message({:type => "DSC", :port => port, :host => host})
    end

    it "used the sequence number passed if it appears" do
      expect(Message).to receive(:new).with({:from => "AGT:#{subject.uuid.gsub("-", "")}", :to => "CLD:#{cloud.uuid.gsub("-", "")}", :type => "DSC", :sequence_number => 3}).and_return(message)
      expect_any_instance_of(UDPSender).to receive(:send).with({host: host, port: port, :message => "SerializedMessage"})
      subject.send_message({:type => "DSC", :port => port, :host => host, :sequence_number => 3})
    end

    it "add the UDP socket info if it is a presence message" do
      allow(subject).to receive(:udp_rx).and_return(udp_socket)
      expect_any_instance_of(UDPSender).to receive(:send).with({host: host, port: port, :message => well_formed_presence_message})
      subject.send_message({:type => "PRS", :port => port, :host => host, :sequence_number => 3})
    end

    it "add the RestAPI info if it is a QNE message" do
      allow(subject).to receive(:udp_rx).and_return(udp_socket)
      expect_any_instance_of(UDPSender).to receive(:send).with({host: host, port: port, :message => well_formed_qne_message})
      subject.send_message({:type => "QNE", :port => port, :host => host, :sequence_number => 3, timestamp: "sometime"})
    end
  end
end