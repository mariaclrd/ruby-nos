require "json"

module RubyNos
  class Formatter
    def convert_to_uuid string_uuid
      string_uuid.match(/(\h{8})(\h{4})(\h{4})(\h{4})(\h{12})/).captures.join("-")
    end

    def uuid_format? uuid
      !!uuid.match(/\h{8}-\h{4}-\h{4}-\h{4}-\h{12}/)
    end

    def uuid_to_string uuid
      uuid.gsub("-", "")
    end

    def parse_message message
      JSON.parse(message, {symbolize_names: true})
    end

    def self.timestamp
      (Time.now.to_f*1000).to_i
    end
  end
end