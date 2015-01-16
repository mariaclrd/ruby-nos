require "securerandom"
require "active_support"

module RubyNos
  class Agent
    include Initializable
    attr_accessor :uuid, :cloud, :udp_tx_socket, :udp_rx_socket, :cloud_uuid, :processor, :port

    def uuid
      @uuid ||= SecureRandom.uuid
    end

    def udp_tx_socket
      @udp_tx_socket ||= UDPSender.new
    end

    def udp_rx_socket
      @udp_rx_socket ||= UDPReceptor.new(port)
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
      message = Message.new({from: "ag:#{uuid}", to: args[:to] || "cd:#{cloud.uuid}", type: args[:type], sequence_number: args[:sequence_number]})
      udp_tx_socket.send({host: args[:host], port: args[:port], message: message.serialize_message})
    end

    private

    def listen
      udp_rx_socket.listen(processor)
    end

    def join_cloud
      send_message({type: 'DSC'})
    end
  end
end