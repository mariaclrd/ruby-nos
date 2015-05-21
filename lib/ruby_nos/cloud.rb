module RubyNos
  class Cloud < ListforAgents
    include Initializable
    attr_accessor :uuid, :current_agent

    alias agents_info list

    def uuid
      @uuid ||= RubyNos.cloud_uuid
    end

    def update agent_info
      self.current_agent = RemoteAgent.new(uuid: agent_info[:agent_uuid], sequence_number: (agent_info[:sequence_number] || nil), timestamp: (agent_info[:timestamp] || timestamp_for_list))
      info = agent_info[:info]
      self.current_agent.endpoints = process_endpoints(info[:endpoints]) if (info && info[:endpoints])

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

    def update_info uuid, agent=nil
      agents_info.select{|e| e[uuid]}.first[uuid] = (agent || self.current_agent)
    end


    private

    def timestamp_for_list
      Formatter.timestamp
    end

    def add_new_agent
      #RubyNos.logger.send(:info, "Added agent #{self.current_agent.uuid}")
      puts "Added agent #{self.current_agent.uuid}"
      agents_info << {self.current_agent.uuid => self.current_agent}
    end

    def process_existent_agent
      if correct_sequence_number? && correct_timestamp?
        update_actual_info
      end
    end

    def remote_agent_on_the_list
      info_on_the_list(self.current_agent.uuid)
    end

    def update_actual_info
      unless same_info?
        prepare_agent
        update_info(self.current_agent.uuid)
      end
    end

    def prepare_agent
      if self.current_agent.endpoints == []
        self.current_agent.endpoints = remote_agent_on_the_list.endpoints
      end
      if self.current_agent.rest_api == nil
        self.current_agent.rest_api = remote_agent_on_the_list.rest_api
      end
    end

    def correct_sequence_number?
      info_on_the_list(self.current_agent.uuid).sequence_number < self.current_agent.sequence_number
    end

    def correct_timestamp?
      timestamp = info_on_the_list(self.current_agent.uuid).timestamp
      ((Formatter.timestamp - RubyNos.keep_alive_time) < timestamp) && (timestamp <= timestamp_for_list)
    end

    def same_info?
      remote_agent_on_the_list.same_timestamp?(self.current_agent) && remote_agent_on_the_list.same_endpoints?(self.current_agent) && remote_agent_on_the_list.same_api?(self.current_agent)
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