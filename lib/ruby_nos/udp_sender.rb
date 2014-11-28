require 'socket'

module RubyNos
  class UDPSender
    #include Initializable
    attr_accessor :receptor_address

    def receptor_address
      @receptor_address ||= []
    end

    def send args={}
      socket = UDPSocket.open
      socket.setsockopt(:IPPROTO_IP, :IP_MULTICAST_TTL, 1)
      socket.send(args[:message].to_s, 0, args[:host] || multicast_address[0], args[:port] || multicast_address[1])
      socket.close
    end

    private

    def multicast_address
      ['224.0.0.1', 3783]
    end
  end
end

sender = RubyNos::UDPSender.new
sender.send({message: "Hello", host: "224.0.0.1", port: 3783})
puts "Message sent"