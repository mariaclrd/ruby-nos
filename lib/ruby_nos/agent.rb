require "securerandom"
require "active_support"

module RubyNos
  class Agent
    include Initializable
    cattr_accessor :uuid, :cloud, :udp_socket

    def uuid
      @@uuid ||= SecureRandom.uuid
    end

    def udp_socket
      @@udp_socket ||= UDPSender.new
    end

    def join_cloud cloud_uuid
      @@cloud = Cloud.new(cloud_uuid)
      @@cloud.add_agent
    end

    def send_message args={}
      message = Message.new({from: "ag:#{@@uuid}", to: args[:to] || "cd:#{@@cloud.uuid}", type: args[:type]})
      udp_socket.send({host: args[:host], port: args[:port], message: message.serialize_message})
    end

    def to_hash
      {
          agent_uuid: @uuid
      }
    end

  end
end