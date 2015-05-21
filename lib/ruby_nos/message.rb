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
      mandatory_fields.merge(optional_fields)
    end

    def serialize_message options = {}
      message = mandatory_fields

      unless options.empty?
        options_hashes = options[:options].map do |option|
          {option => optional_fields.fetch(option)}
        end

        options_hashes.each do |hashie|
          message.merge!(hashie)
        end
      end
      message.merge!({sg: signature_generator.generate_signature(message.to_s)})
    end

    def sequence_number
      @sequence_number || Time.now.to_i
    end

    private

    def mandatory_fields
      {
          v:  self.version  || "1.0",
          ty: self.type,
          fr: self.from,
          to: self.to,
          hp: self.hops     || RubyNos.hops,
          rx: 0,
          ts: self.timestamp || generate_miliseconds_timestamp,
          sq: self.sequence_number
      }
    end

    def generate_miliseconds_timestamp
      Formatter.timestamp
    end

    def signature_generator
      @signature_generator ||= SignatureGenerator.new
    end

    def optional_fields
      {
          rx: self.reliable || false,
          dt: self.data
      }
    end
  end
end