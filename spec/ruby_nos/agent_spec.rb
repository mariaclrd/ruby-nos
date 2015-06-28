require "spec_helper"

describe "RubyNos::Agent" do
  subject{Agent.new(udp_tx: udp_sender, udp_rx: udp_receptor, cloud: cloud, processor: processor, rest_api: rest_api)}
  let(:udp_receptor)    {double("UDPReceptor", listen: nil)}
  let(:udp_sender)      {double("UDPSender", send: nil)}
  let(:cloud)           {double("cloud", uuid: "abcd", list: list)}
  let(:list)            {double("list", list_of_keys: [])}
  let(:processor)       {double("processor")}
  let(:rest_api)        {double("rest_api", endpoints: [], to_hash: {})}

  describe "mantain cloud" do
    context "without agents on the cloud" do
      it "ask for other agents" do
        expect(udp_sender).to receive(:send).twice
        thread = subject.maintain_cloud
        sleep 0.1
        thread.kill
      end
    end

    context "with some agent on the cloud" do
      let(:list)  {double("list", list_of_keys: [agent.uuid])}
      let(:agent) {double("agent", uuid: "12345", timestamp: Time.now)}

      before(:each) do
        allow(list).to receive(:info_for).with(agent.uuid).and_return(agent)
      end

      context "it exists a previous message of the agent" do
        it "sends_a_ping_message to the agent" do
          expect(udp_sender).to receive(:send).exactly(3).times
          allow(subject).to receive(:last_message_exists?).and_return(true)
          thread = subject.maintain_cloud
          sleep 0.1
          thread.kill
        end
      end

      context "it does not exists a previous message of the agent" do
        it "eliminates the agent from the list" do
          expect(udp_sender).to receive(:send).twice
          allow(subject).to receive(:last_message_exists?).and_return(false)
          expect(list).to receive(:eliminate).with(agent.uuid)
          thread = subject.maintain_cloud
          sleep 0.1
          thread.kill
        end
      end
    end
  end

  describe "#join_cloud" do
    let(:receptor_info) {{present: 1, endpoints: []}}

    before(:each) do
      allow(subject).to receive(:receptor_info).and_return(receptor_info)
    end

    it "sends only a presence message if the agent does not have an API with endpoints" do
      expect(udp_sender).to receive(:send).once
      subject.join_cloud
    end

    it "sends a presence and a qne if the agent has an API with endpoints" do
      allow(rest_api).to receive(:endpoints).and_return(["one_endpoint"])
      expect(udp_sender).to receive(:send).twice
      subject.join_cloud
    end
  end

  describe "#send_desconnection_message" do
    it "sends a message with presence 0" do
      expect(udp_sender).to receive(:send).once
      subject.send_desconnection_message
    end
  end


  describe "#listen" do
    it "starts the udp receptor" do
      expect(udp_receptor).to receive(:listen)
      subject.listen
    end
  end


  describe "#send_message" do
    let(:message){double("Message", :serialize => "SerializedMessage")}
    let(:rest_api) {RestApi.new}
    let(:receptor_info) {{present: 1, endpoints: []}}
    let(:well_formed_presence_message){Message.new({from: "AGT:#{subject.uuid.gsub("-", "")}", to: "CLD:#{subject.cloud.uuid.gsub("-", "")}", type: "PRS", timestamp: "sometime", data: receptor_info}).serialize}
    let(:well_formed_qne_message){Message.new({from: "AGT:#{subject.uuid.gsub("-", "")}", to: "CLD:#{subject.cloud.uuid.gsub("-", "")}", type: "QNE", timestamp: "sometime", data: rest_api.to_hash}).serialize}
    let(:host) {"0.0.0.0"}
    let(:port) {"3784"}

    before(:each) do
      subject.cloud = cloud
      subject.rest_api = rest_api
      allow_any_instance_of(Message).to receive(:generate_miliseconds_timestamp).and_return("sometime")
    end

    it "sends a message using the UDP Socket" do
      expect(Message).to receive(:new).with({:from => "AGT:#{subject.uuid.gsub("-", "")}", :to => "CLD:#{cloud.uuid.gsub("-", "")}", :type => "DSC"}).and_return(message)
      expect(udp_sender).to receive(:send).with({host: host, port: port, :message => "SerializedMessage"})
      subject.send_message({:type => "DSC", :port => port, :host => host})
    end

    it "add the UDP socket info if it is a presence message" do
      expect(subject).to receive(:receptor_info).and_return(receptor_info)
      expect(udp_sender).to receive(:send).with({host: host, port: port, :message => well_formed_presence_message})
      subject.send_message({:type => "PRS", :port => port, :host => host})
    end

    it "add the RestAPI info if it is a QNE message" do
      expect(udp_sender).to receive(:send).with({host: host, port: port, :message => well_formed_qne_message})
      subject.send_message({:type => "QNE", :port => port, :host => host})
    end
  end
end