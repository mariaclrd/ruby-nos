require "securerandom"

module RubyNos
  class Message

    attr_accessor :uuid, :version, :from, :to, :hops, :seq, :reliable, :data, :sig, :rnd

    def create_message args={}
      @uuid =     args[:uuid] || SecureRandom.uuid
      @version =  args[:version] || 1.0
      @from =     args[:from]
      @to =       args[:to]
      @hops =     args[:hops]
      @seq =      args[:seq]
      @reliable = args[:reliable]
      @data =     args[:data]
      @sig =      args[:sig]
      @rnd = (sig == nil ? nil : (args[:rnd] == nil ? SecureRandom.base64 : args[:rnd]))
    end

    def serialize_message
    {
        uuid:     @uuid,
        version:  @version,
        from:     @from,
        to:       @to,
        hops:     @hops,
        seq:      @seq,
        reliable: @reliable,
        data:     @data,
        sig:      @sig,
        rnd:      @rnd
    }
    end
  end
end