require "securerandom"
require "active_support"

module RubyNos
  class Agent
    include Initializable
    attr_accessor :uuid, :cloud, :udp_tx, :udp_rx, :cloud_uuid, :processor, :port

    def uuid
      @uuid ||= SecureRandom.uuid
    end

    def udp_tx
      @udp_tx ||= UDPSender.new
    end

    def udp_rx
      @udp_rx ||= UDPReceptor.new(port)
    end

    def cloud
      @cloud      ||= Cloud.new(uuid: cloud_uuid)
    end

    def processor
      @processor ||= Processor.new(self)
    end

    def configure
      listen
      join_cloud
    end

    def send_message args={}
      if args[:type] == "PRS"
        data = receptor_info
      end

      if data
        message = Message.new({from: "ag:#{uuid}", to: args[:to] || "cd:#{cloud.uuid}", type: args[:type], sequence_number: args[:sequence_number], data: data}).serialize_with_optional_fields({options: [:dt]})
      else
        message = Message.new({from: "ag:#{uuid}", to: args[:to] || "cd:#{cloud.uuid}", type: args[:type], sequence_number: args[:sequence_number]}).serialize_message
      end

      udp_tx.send({host: args[:host], port: args[:port], message: message})
    end

    private

    def receptor_info
      {endpoints: ["UDP,#{udp_rx.socket.connect_address.ip_port},#{udp_rx.socket.connect_address.ip_address}"]}
    end

    def listen
      udp_rx.listen(processor)
    end

    def join_cloud
      send_message({type: 'DSC'})
    end
  end
end