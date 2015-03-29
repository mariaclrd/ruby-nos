module RubyNos
  class Cloud < ListforAgents
    include Initializable
    attr_accessor :uuid, :current_agent_uuid, :current_info, :current_sequence_number

    alias agents_info list

    def uuid
      @uuid ||= RubyNos.cloud_uuid
    end

    def update agent_uuid, sequence_number=nil, info=nil
      self.current_agent_uuid = agent_uuid
      self.current_info = info ? process_info(info) : {}
      self.current_sequence_number = sequence_number || nil

      if !is_on_the_list?(self.current_agent_uuid)
        add_new_agent
      else
        process_existent_agent
      end
    end

    private

    def add_new_agent
      agents_info << {self.current_agent_uuid => info_to_be_stored}
    end

    def process_existent_agent
      if correct_sequence_number?
        update_actual_info
      end
    end

    def update_actual_info
      unless (same_info?(info_on_the_list(self.current_agent_uuid), self.current_info) || self.current_info == {})
        update_info(self.current_agent_uuid, info_to_be_stored)
      end
    end

    def info_to_be_stored
      self.current_info.merge(sequence_number: self.current_sequence_number)
    end

    def correct_sequence_number?
      info_on_the_list(self.current_agent_uuid)[:sequence_number] < self.current_sequence_number
    end

    def same_info? original_info, new_info
      original_info == new_info
    end

    def update_info uuid, info
      agents_info.select{|e| e[uuid]}.first[uuid] = info
    end

    def process_info info
      info_hash = {}

      if endpoints = info[:endpoints]
        endpoints_info = []
        endpoints.each do |endpoint|
          e_info = endpoint.split(",")
          endpoints_info << {type: e_info[0], port: e_info[1], address: e_info[2]}
        end
        info_hash.merge!({endpoints: endpoints_info})
      end
    end
  end
end