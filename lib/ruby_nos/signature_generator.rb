require "digest"

module RubyNos
  class SignatureGenerator

    attr_accessor :key

    def key
      @key ||= RubyNos.signature_key
    end

    def generate_signature data
      digest = OpenSSL::Digest.new('sha1')
      OpenSSL::HMAC.hexdigest(digest, key, data)
    end

    def check_signature data, signature
      generated_signature = generate_signature(data)
      signature == generated_signature
    end
  end
end