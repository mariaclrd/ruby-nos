require 'socket'
require 'pry'

module RubyNos
  class UDPSender

    def initialize
      @socket = UDPSocket.new
      @socket.bind(nil, 6600)
    end

    def send_message message, host, port
      @socket.send(message, 0, host, port)
    end
  end
end

