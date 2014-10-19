require "securerandom"
require "initializable"

module RubyNos
  class Message

    include Initializable
    attr_accessor :version, :from, :to, :hops, :seq, :reliable, :data, :sig, :rnd

    def serialize_message
    {
        v:  @version,
        ty: @type,
        fr: "ag:#{@from}",
        to: "ag:#{@to}",
        hp: @hops,
        rx: @reliable,
        dt: @data,
        sg: @sig,
    }
    end
  end
end