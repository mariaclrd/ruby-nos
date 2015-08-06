module RubyNos
  class Cloud
    include Initializable
    attr_accessor :uuid, :current_agent, :list

    def uuid
      @uuid ||= RubyNos.cloud_uuid
    end

    def list
      @list ||= List.new
    end

    def update agent_info
      if agent_info.is_a?(Hash)
        self.current_agent = build_remote_agent(agent_info)
      else
        self.current_agent = agent_info
      end

      if list.is_on_the_list?(self.current_agent.uuid)
        update_actual_info
      else
        RubyNos.logger.send(:info, "Added agent #{self.current_agent.uuid}")
        list.add(self.current_agent)
      end
    end

    private

    def build_remote_agent agent_info
      agent = RemoteAgent.new(uuid: agent_info[:agent_uuid], timestamp: (agent_info[:timestamp] || timestamp_for_list))
      info = agent_info[:info]
      agent.endpoints = process_endpoints(info[:endpoints]) if (info && info[:endpoints])
      agent
    end

    def timestamp_for_list
      Formatter.timestamp
    end

    def update_actual_info
      if correct_timestamp? && !same_info?
        prepare_agent
        list.update(self.current_agent.uuid, self.current_agent)
      end
    end

    def remote_agent_on_the_list
      list.info_for(self.current_agent.uuid)
    end

    def prepare_agent
      if self.current_agent.endpoints == []
        self.current_agent.endpoints = remote_agent_on_the_list.endpoints if remote_agent_on_the_list.endpoints
      end
      if self.current_agent.rest_api == nil
        self.current_agent.rest_api = remote_agent_on_the_list.rest_api if remote_agent_on_the_list.rest_api
      end
    end

    def correct_timestamp?
      timestamp = current_agent.timestamp
      ((timestamp_for_list - RubyNos.keep_alive_time) < timestamp) && (timestamp <= timestamp_for_list)
    end

    def same_info?
      remote_agent_on_the_list.same_endpoints?(self.current_agent) && remote_agent_on_the_list.same_api?(self.current_agent) && remote_agent_on_the_list.same_timestamp?(self.current_agent)
    end

    def process_endpoints endpoints
      [].tap do |endpoints_info|
        endpoints.each do |endpoint|
          e_info = endpoint.split(",")
          endpoints_info << Endpoint.new({type: e_info[0], port: e_info[1], host: e_info[2]})
        end
      end
    end
  end
end
