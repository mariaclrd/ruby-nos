module RubyNos
  class Message

    attr_accessor :uuid, :version, :from, :to, :hops, :seq, :reliable, :data, :sig, :rnd

    def create_message args={}
      @uuid =     args[:uuid]
      @version =  args[:version] || 1.0
      @from =     args[:from]
      @to =       args[:to]
      @hops =     args[:hops]
      @seq =      args[:seq]
      @reliable = args[:reliable]
      @seq =      args[:seq]
      @data =     args[:data]
      @sig =      args[:sig]
      @rnd ||= (sig == null ? null : SecureRandom.base64)
    end


  end
end