module RubyNos
  class Cloud
    include Initializable
    attr_accessor :uuid, :agents_info

    def agents_info
      @agents_info ||= []
    end

    def update agent_uuid, info
      if !is_on_the_list?(agent_uuid)
        agents_info << {agent_uuid => info}
      else
        unless same_info?(find_info_for_agent_uuid(agent_uuid), info)
          update_info(agent_uuid, info)
        end
      end
    end

    def find_info_for_agent_uuid uuid
      agents_info.map{|e| e[uuid]}.first
    end

    def is_on_the_list? uuid
      agents_info.map{|e| e.keys}.flatten.include?(uuid)
    end

    private

    def same_info? original_info, new_info
      original_info == new_info
    end

    def update_info uuid, info
      agents_info.select{|e| e[uuid]}.first[uuid] = info
    end

  end
end