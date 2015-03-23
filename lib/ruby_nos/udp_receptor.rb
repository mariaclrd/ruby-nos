require 'socket'
require 'ipaddr'

module RubyNos
  class UDPReceptor
    include Initializable
    attr_accessor :socket

    MULTICAST_ADDR = "230.31.32.33"


    def initialize port
      @socket = UDPSocket.new
      configure(port)
    end

    def receptor_address
      @receptor_address ||= []
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

    def configure port
      puts "Binding socket to #{bind_addr} IP"
      membership = IPAddr.new(MULTICAST_ADDR).hton + IPAddr.new(bind_addr).hton
      @socket.setsockopt(:IPPROTO_IP, :IP_ADD_MEMBERSHIP, membership)
      @socket.setsockopt(:SOL_SOCKET, :SO_REUSEPORT, 1)
      @socket.setsockopt(:SOL_SOCKET, :SO_REUSEADDR, 1)
      @socket.bind(bind_addr, port)
    end

    def bind_addr
      #Socket.ip_address_list.find { |ai| ai.ipv4? && !ai.ipv4_loopback? }.ip_address
      "0.0.0.0"
    end
  end
end
