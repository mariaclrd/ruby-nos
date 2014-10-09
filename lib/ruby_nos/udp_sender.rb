require 'socket'
require 'pry'

module RubyNos
  class UDPSender

    attr_accessor :socket, :host, :port

    def initialize port=6600, host
      @socket = UDPSocket.new
      @port = port
      @host = host
      @socket.bind(nil, @port)
    end

    def send message
      @socket.send(message, 0, @host, @port)
    end
  end
end

