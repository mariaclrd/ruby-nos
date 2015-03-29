require "securerandom"
require "initializable"

module RubyNos
  class Message

    include Initializable
    attr_accessor :version, :from, :type, :to, :hops, :reliable, :data, :signature, :sequence_number
    alias :v= :version=
    alias :fr= :from=
    alias :ty= :type=
    alias :hp= :hops=
    alias :rx= :reliable=
    alias :dt= :data=
    alias :sq= :sequence_number=
    alias :sg= :signature=

    def serialize_message
      mandatory_fields.merge!({sg: signature_generator.generate_signature(mandatory_fields.to_s)})
    end

    def serialize_with_optional_fields options

      message = mandatory_fields

      options_hashes = options[:options].map do |option|
        {option => optional_fields.fetch(option)}
      end

      options_hashes.each do |hashie|
        message.merge!(hashie)
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
          hp: self.hops     || 2,
          rx: 0,
          sq: self.sequence_number
      }

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