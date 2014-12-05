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
      agents_info << {:agent_uuid => message[:fr], :endpoints => message[:dt][:ep], :routes => message[:dt][:ru], :application => message[:dt][:ap]}
    end

    def find_for_agent_uuid uuid
      agents_info.select{|e| e[:agent_uuid] == uuid}.first
    end

    def find_for_app app_name
      agents_info.select{|e| e[:application] == app_name}.first
    end
  end
end