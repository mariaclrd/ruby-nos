module RubyNos
  class Cloud < ListforAgents
    include Initializable
    attr_accessor :uuid, :current_agent

    alias agents_info list

    def uuid
      @uuid ||= RubyNos.cloud_uuid
    end

    def update agent_info
      self.current_agent = RemoteAgent.new(uuid: agent_info[:agent_uuid], sequence_number: (agent_info[:sequence_number] || nil), timestamp: (agent_info[:timestamp] || Time.now))
      info = agent_info[:info]
      self.current_agent.endpoints = process_endpoints(info[:endpoints]) if (info && info[:endpoints])
      self.current_agent.rest_api = info[:rest_api] if (info && info[:rest_api])

      if !is_on_the_list?(self.current_agent.uuid)
        add_new_agent
      else
        process_existent_agent
      end
    end

    def insert_new_remote_agent agent
      self.current_agent = agent
      add_new_agent
    end

    private

    def add_new_agent
      agents_info << {self.current_agent.uuid => self.current_agent}
    end

    def process_existent_agent
      if correct_sequence_number?
        update_actual_info
      end
    end

    def update_actual_info
      unless (same_info?(info_on_the_list(self.current_agent.uuid).endpoints.map{|e| e.to_hash}, self.current_agent.endpoints.map{|e| e.to_hash}) || self.current_agent.endpoints == [])
        update_info(self.current_agent.uuid)
      end
    end

    def correct_sequence_number?
      info_on_the_list(self.current_agent.uuid).sequence_number < self.current_agent.sequence_number
    end

    def same_info? original_info, new_info
      original_info == new_info
    end

    def update_info uuid
      agents_info.select{|e| e[uuid]}.first[uuid] = self.current_agent
    end

    def process_endpoints endpoints
      endpoints_info = []
      endpoints.each do |endpoint|
        e_info = endpoint.split(",")
        endpoints_info << Endpoint.new({type: e_info[0], port: e_info[1], host: e_info[2]})
      end
      endpoints_info
    end
  end
end