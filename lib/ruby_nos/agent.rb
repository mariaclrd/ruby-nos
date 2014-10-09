require "securerandom"

module RubyNos
  class Agent
    attr_accessor :uuid, :cloud, :udp_socket

    def initialize
      @uuid ||= SecureRandom.uuid
    end

    def udp_socket
      @udp_socket ||= UDPSender.new
    end

    def join_cloud cloud_uuid
      @cloud = Cloud.new(cloud_uuid)
      @cloud.add_agent
    end

    def send_message args={}
      message = Message.new({from: @uuid, to: @cloud.uuid, type: args[:type]})
      udp_socket.send({host: args[:host], port: args[:port], message: message.serialize_message})
    end


  end
end