module RubyNos
  class Cloud
    include Initializable
    attr_accessor :uuid, :agents_info

    def agents_info
      @agents_info ||= []
    end

    def update agent_uuid, info=""
      if !is_on_the_list?(agent_uuid)
        agents_info << {agent_uuid => process_info(info)}
      else
        unless same_info?(find_info_for_agent_uuid(agent_uuid), info)
          update_info(agent_uuid, process_info(info))
        end
      end
    end

    def delete_from_cloud agent_uuid
      agents_info.delete_if{|e| e.keys.first == agent_uuid}
    end

    def list_of_agents
      agents_info.map{|e| e.keys}.flatten
    end

    def find_info_for_agent_uuid uuid
      agents_info.map{|e| e[uuid]}.first
    end

    def is_on_the_list? uuid
      list_of_agents.include?(uuid)
    end

    private

    def process_info info
      info_hash = {}

      if endpoints = info["endpoints"]
        info_to_be_stored = []
        endpoints.each do |endpoint|
          e_info = endpoint.split(",")
          info_to_be_stored << {type: e_info[0], port: e_info[1], address: e_info[2]}
        end
        info_hash.merge!({endpoints: info_to_be_stored})
      end
    end

    def same_info? original_info, new_info
      original_info == new_info
    end

    def update_info uuid, info
      agents_info.select{|e| e[uuid]}.first[uuid] = info
    end

  end
end