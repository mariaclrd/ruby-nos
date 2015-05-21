require 'socket'
require 'ipaddr'

module RubyNos
  class UDPReceptor
    attr_accessor :port

    def initialize
      configure
    end

    def port
      @port ||= RubyNos.port
    end

    def multicast_address
      @multicast_address ||= RubyNos.group_address
    end

    def socket
      @socket ||= UDPSocket.new
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
      #RubyNos.logger.send(:info, "Binding socket to #{bind_addr} IP")
      puts "Binding socket to #{bind_addr} IP"
      membership = IPAddr.new(multicast_address).hton + IPAddr.new(bind_addr).hton
      socket.setsockopt(:IPPROTO_IP, :IP_ADD_MEMBERSHIP, membership)
      socket.setsockopt(:SOL_SOCKET, :SO_REUSEPORT, 1)
      socket.setsockopt(:SOL_SOCKET, :SO_REUSEADDR, 1)
      socket.bind(bind_addr, port)
    end

    def bind_addr
      "0.0.0.0"
    end
  end
end
