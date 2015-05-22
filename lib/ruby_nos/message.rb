require "securerandom"
require "initializable"

module RubyNos
  class Message

    include Initializable
    attr_accessor :version, :from, :type, :to, :hops, :reliable, :data, :signature, :sequence_number, :id, :timestamp
    alias :v= :version=
    alias :fr= :from=
    alias :ty= :type=
    alias :hp= :hops=
    alias :rx= :reliable=
    alias :dt= :data=
    alias :sq= :sequence_number=
    alias :sg= :signature=
    alias :ts= :timestamp=

    def to_hash
      {
          v:  self.version  || "1.0",
          ty: self.type,
          fr: self.from,
          to: self.to,
          hp: self.hops     || RubyNos.hops,
          ts: self.timestamp || generate_miliseconds_timestamp,
          sq: self.sequence_number,
          rx: self.reliable || 0,
          dt: self.data
      }.delete_if{|key, value| value==nil  || value == {}}
    end

    def serialize
      to_hash.merge!({sg: signature_generator.generate_signature(to_hash.to_s)})
    end

    def sequence_number
      @sequence_number || Time.now.to_i
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