require 'socket'
require 'pry'

module RubyNos
  class UDPSender

    attr_accessor :socket

    def initialize port=6600
      @socket = UDPSocket.new
      @socket.bind(nil, port)
    end

    def send_message message, host, port
      @socket.send(message, 0, host, port)
    end
  end
end

