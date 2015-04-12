require 'socket'
require 'json'

module RubyNos
  class UDPSender
  include Initializable

    def send args={}
      socket = UDPSocket.open
      socket.setsockopt(:IPPROTO_IP, :IP_MULTICAST_TTL, 1)
      RubyNos.logger.send(:info, "Message sent: #{args[:message]}")
      socket.send(args[:message].to_json, 0, args[:host] || multicast_address, args[:port] || port)
      socket.close
    end

    private

    def multicast_address
      @multicast_address ||= RubyNos.group_address
    end

    def port
      @port ||= RubyNos.port
    end
  end
end