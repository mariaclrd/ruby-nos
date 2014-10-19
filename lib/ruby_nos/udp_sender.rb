require 'socket'

module RubyNos
  class UDPSender
    include Initializable
    attr_accessor :socket, :port, :message, :receptor_address

    def initialize
      @socket = UDPSocket.new
      @socket.bind("127.0.0.1", 0)
      @port = Socket.getnameinfo(@socket.getsockname()).last
    end

    def send args={}
      @socket.send(args[:message].to_s, 0, args[:host] || @receptor_address.last, args[:port] || @receptor_addres[1])
    end

    def receive
      message, @receptor_address = @socket.recvfrom_nonblock(65535)
      message
    end
  end
end

