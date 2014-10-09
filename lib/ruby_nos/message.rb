require "securerandom"

module RubyNos
  class Message

    attr_accessor :version, :from, :to, :hops, :seq, :reliable, :data, :sig, :rnd

    def initialize args={}
      @version =  args[:version] || 1.0
      @type =     args[:type]
      @from =     args[:from]
      @to =       args[:to]
      @sig =      args[:sig]
      @hops =     args[:hops] || 3
      @reliable = args[:reliable] || false
      @data =     args[:data] || nil
    end

    def serialize_message
    {
        v:  @version,
        ty: @type,
        fr: "ag:#{@from}",
        to: "cd:#{@to}",
        hp: @hops,
        rx: @reliable,
        dt: @data,
        sg: @sig,
    }
    end
  end
end