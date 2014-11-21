require "securerandom"
require "active_support"

module RubyNos
  class Agent
    include Initializable
    attr_accessor :uuid, :cloud, :udp_socket, :port, :cloud_uuid

    def uuid
      @uuid ||= SecureRandom.uuid
    end

    def udp_socket
      @udp_socket ||= UDPSender.new(port: @port)
    end

    def cloud
      @cloud      ||= Cloud.new(uuid: cloud_uuid)
    end

    def configure
      join_cloud
      check_health
    end

    def join_cloud
      send_message({type: 'DSC', host: :broadcast, port: :broadcast})
    end

    def send_message args={}
      message = Message.new({from: "ag:#{uuid}", to: args[:to] || "cd:#{cloud.uuid}", type: args[:type]})
      udp_socket.send({host: args[:host], port: args[:port], message: message.serialize_message})
    end

    def to_hash
      {
          agent_uuid: @uuid
      }
    end

  end
end