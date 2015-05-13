require "json"

module RubyNos
  class Formatter
    def convert_to_uuid string_uuid
      string_uuid[0,8] + "-" + string_uuid[8,4]+"-"+ string_uuid[12,4] + "-" + string_uuid[16,4]+ "-" + string_uuid[20..-1]
    end

    def uuid_format? uuid
      !!uuid.match(/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/)
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