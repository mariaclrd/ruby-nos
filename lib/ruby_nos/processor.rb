require "json"

module RubyNos
  class Processor

    attr_accessor :agent

    def agent
      @agent ||= Agent.new
    end

    def process_message message
      message = parsed_message(message)

      if message[:ty] == "PIN"
        if agent_receptor?(message[:to])
          send_response "PON"
        end
      else
        if cloud_receptor?(message[:to])
          if message[:ty] == "PON"
            update_cloud(message[:fr])
          elsif message[:ty] == "ACK"
            check_hash(message)
          elsif message[:ty] == "PRS"
            update_cloud(message)
            extract_info(message)
          elsif message[:ty] == "DSC"
            send_response "PRS"
          end
        end
      end
    end


    private

    def parsed_message message
      parsed_message = JSON.parse(message)
      parsed_message.inject({}){|pair,(k,v)| pair[k.to_sym] = v; pair}
    end

    def agent_receptor? to_param
      "ag:#{agent.uuid}" == to_param
    end

    def cloud_receptor? to_param
      "cd:#{agent.cloud.uuid}" == to_param
    end

    def get_from_uuid from_param
      (from_param.split("") - ["a", "g", ":"]).join()
    end

    def send_response type
      agent.send_message({type: type})  #is sent to the entire cloud
    end

    def update_cloud from_param
      unless (agent.cloud.agents_list.select{|agent| "ag:#{agent}" == from_param}).any?
        agent.cloud.add_agent get_from_uuid(from_param)
      end
    end


    def check_hash message
      nil
    end

    def extract_info message
      nil
    end
  end
end