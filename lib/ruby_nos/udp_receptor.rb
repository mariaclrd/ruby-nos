require 'socket'
require 'ipaddr'

module RubyNos
  class UDPReceptor
    #include Initializable
    attr_accessor :socket, :port, :receptor_address

    MULTICAST_ADDR = "224.0.0.1"
    BIND_ADDR      = "0.0.0.0"
    PORT           = 3783


    def initialize
      @socket = UDPSocket.new
      configure
    end

    def receptor_address
      @receptor_address ||= []
    end

    def receive
      @socket.recvfrom(16).first
    end

    def listen processor
      thread = Thread.new do
        loop do
          message = @socket.recvfrom(512).first
          processor.process_message(message)
        end
      end
      thread
    end

    private

    def configure
      membership = IPAddr.new(MULTICAST_ADDR).hton + IPAddr.new(BIND_ADDR).hton
      @socket.setsockopt(:IPPROTO_IP, :IP_ADD_MEMBERSHIP, membership)
      @socket.setsockopt(:SOL_SOCKET, :SO_REUSEPORT, 1)
      @socket.bind(BIND_ADDR, PORT)
    end
  end
end

if __FILE__ == $0
  receptor = RubyNos::UDPReceptor.new
  receptor.listen.join
end