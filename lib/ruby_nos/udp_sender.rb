require 'socket'
require 'json'

module RubyNos
  class UDPSender
  include Initializable

    def send args={}
      socket = UDPSocket.open
      socket.setsockopt(:IPPROTO_IP, :IP_MULTICAST_TTL, 1)
      socket.send(args[:message].to_json, 0, args[:host] || multicast_address[0], args[:port] || multicast_address[1])
      socket.close
    end

    private

    def multicast_address
      ['230.31.32.33', 3784]
    end
  end
end