require "securerandom"
require "initializable"

module RubyNos
  class Message

    include Initializable
    attr_accessor :version, :from, :type, :to, :hops, :seq, :reliable, :data, :sig, :rnd

    def serialize_message
    {
        v:  @version  || "v1.0",
        ty: @type,
        fr: @from,
        to: @to,
        hp: @hops     || 1,
        sg: @sig,
    }
    end

    def serialize_with_extra_headers
      serialize_message.merge({
       rx: @reliable || false,
       dt: @data,
                              })
    end
  end
end