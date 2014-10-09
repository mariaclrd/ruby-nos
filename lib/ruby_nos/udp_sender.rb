require 'socket'

module RubyNos
  class UDPSender

    attr_accessor :socket, :port

    def initialize
      @socket = UDPSocket.new
      @socket.bind("127.0.0.1", 0)
      @port = Socket.getnameinfo(@socket.getsockname()).last
    end

    def send args={}
      @socket.send(args[:message].to_s, 0, args[:host], args[:port])
    end
  end
end

