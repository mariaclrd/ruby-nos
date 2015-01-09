module RubyNos
  class Cloud
    include Initializable
    attr_accessor :uuid, :agents_list, :agents_info

    def agents_list
      @agents_list ||= []
    end

    def agents_info
      @agents_info ||= []
    end

    def add_agent uuid
      agents_list << uuid
    end

    def is_on_the_list? uuid
      agents_list.include?(uuid)
    end

    def store_info message
      info_to_be_stored = {:agent_uuid => message[:fr]}
      info_to_be_stored.merge!(extract_data(message[:dt])) if message[:dt]
      agents_info << info_to_be_stored
    end

    def find_for_agent_uuid uuid
      agents_info.select{|e| e[:agent_uuid] == uuid}.first
    end

    def find_for_app app_name
      agents_info.select{|e| e[:application] == app_name}.first
    end

    private

    def extract_data args ={}
      endpoints = routes = application = {}
      (endpoints = {:endpoints => args[:ep]}) if args[:ep]
      (routes = {:routes => args[:ru]}) if args[:ru]
      (application = {:application => args[:ap]}) if args[:ap]
      endpoints.merge(routes).merge(application)
    end
  end
end