require "securerandom"
require "initializable"

module RubyNos
  class Message

    include Initializable
    attr_accessor :version, :from, :type, :to, :hops, :reliable, :data, :sig, :rnd, :sequence_number
    alias :v= :version=
    alias :fr= :from=
    alias :ty= :type=
    alias :hp= :hops=
    alias :rx= :reliable=
    alias :dt= :data=
    alias :sq= :sequence_number=


    def serialize_message
    {
        v:  self.version  || "1.0",
        ty: self.type,
        fr: self.from,
        to: self.to,
        hp: self.hops     || 2,
        #sg: @sig,
        sq: self.sequence_number
    }
    end

    def serialize_with_optional_fields options

      message = serialize_message

      options_hashes = options[:options].map do |option|
        {option => optional_fields.fetch(option)}
      end

      options_hashes.each do |hashie|
        message.merge!(hashie)
      end

      message
    end

    def sequence_number
      @sequence_number || Time.now.to_i
    end

    private

    def optional_fields
      {
          rx: self.reliable || false,
          dt: self.data
      }
    end
  end
end