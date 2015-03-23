require "securerandom"
require "initializable"

module RubyNos
  class Message

    include Initializable
    attr_accessor :version, :from, :type, :to, :hops, :reliable, :data, :sig, :rnd, :sequence_number

    def serialize_message
    {
        v:  @version  || "1.0",
        ty: @type,
        fr: @from,
        to: @to,
        rx: 0,
        hp: @hops     || 2,
        #sg: @sig,
        sq: sequence_number
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
          rx: @reliable || false,
          dt: @data
      }
    end
  end
end