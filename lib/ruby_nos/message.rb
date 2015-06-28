require "securerandom"
require "initializable"

module RubyNos
  class Message
    include Aliasing

    include Initializable
    attr_accessor :version, :from, :type, :to, :hops, :reliable, :data, :id, :signature, :timestamp
    attr_alias :v,  :version
    attr_alias :fr, :from
    attr_alias :ty, :type
    attr_alias :hp, :hops
    attr_alias :rx, :reliable
    attr_alias :dt, :data
    attr_alias :sg, :signature
    attr_alias :ts, :timestamp

    def to_hash
      {
          v:  self.version  || "1.0",
          ty: self.type,
          fr: self.from,
          to: self.to,
          hp: self.hops     || RubyNos.hops,
          ts: self.timestamp || generate_miliseconds_timestamp,
          rx: self.reliable || 0,
          dt: self.data
      }.delete_if{|key, value| value==nil  || value == {}}
    end

    def serialize
      message = to_hash
      message.merge!({sg: signature_generator.generate_signature(message.to_s)})
    end

    private

    def generate_miliseconds_timestamp
      Formatter.timestamp
    end

    def signature_generator
      @signature_generator ||= SignatureGenerator.new
    end
  end
end