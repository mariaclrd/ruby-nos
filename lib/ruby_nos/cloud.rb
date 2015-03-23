module RubyNos
  class Cloud < ListforAgents
    include Initializable
    attr_accessor :uuid

    alias agents_info list

    def update agent_uuid, info=""
      info_to_be_processed = info ?  process_info(info) : {}
      if !is_on_the_list?(agent_uuid)
        agents_info << {agent_uuid => info_to_be_processed}
      else
        unless (same_info?(info_on_the_list(agent_uuid), info_to_be_processed) || info_to_be_processed == {})
          update_info(agent_uuid, info_to_be_processed)
        end
      end
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