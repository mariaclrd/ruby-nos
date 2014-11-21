require 'socket'

module RubyNos
  class UDPSender
    include Initializable
    attr_accessor :socket, :port, :message, :receptor_address

    def initialize opts={}
      @socket = UDPSocket.new
      @socket.bind("127.0.0.1", opts[:port] || 0)
      @socket.setsockopt(Socket::SOL_SOCKET, Socket::SO_BROADCAST, true)
      @port = port || Socket.getnameinfo(@socket.getsockname()).last
    end

    def receptor_address
      @receptor_address ||= []
    end

    def send args={}
      check_broadcast_host_receptor args[:host]
      check_broadcast_port_receptor args[:port]
      @socket.send(args[:message].to_s, 0, receptor_address[2], receptor_address[1])
    end

    def receive
      message, @receptor_address = @socket.recvfrom_nonblock(65535)
      message_received message
    end

    def message_received message
       message if message
    end

    private

    def check_broadcast_host_receptor host
      if host == :broadcast
        receptor_address[2] = broadcast_address[0]
      else
        receptor_address[2] = host
      end
    end

    def check_broadcast_port_receptor port
      if port == :broadcast
        receptor_address[1] = broadcast_address[1]
      else
        receptor_address[1] = port
      end
    end

    def broadcast_address
      ['255.255.255.255', 33333]
    end
  end
end

