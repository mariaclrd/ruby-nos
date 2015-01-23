require "json"
require "digest"

module RubyNos
  class Processor

    attr_accessor :agent, :sequence_numbers

    def initialize agent
      @agent = agent
    end

    def process_message message
      message = parsed_message(message)

      if message[:ty] == "PIN"
        if agent_receptor?(message[:to])
          sequence_number = get_sequence_number_for_response message[:sq]
          send_response "PON", sequence_number
        end
      else
        if cloud_receptor?(message[:to])
          if message[:ty] == "PON"
            agent.cloud.update(get_from_uuid(message[:fr]), message[:dt])
          elsif message[:ty] == "PRS"
            agent.cloud.update(get_from_uuid(message[:fr]), message[:dt])
          elsif message[:ty] == "DSC"
            sequence_number = get_sequence_number_for_response message[:sq]
            send_response "PRS", sequence_number
          end
        end
      end
    end

    private

    def parsed_message message
      parsed_message = JSON.parse(message)
      keyed_message = parsed_message.inject({}){|pair,(k,v)| pair[k.to_sym] = v; pair}
      (keyed_message[:dt] = keyed_message[:dt].inject({}){|pair,(k,v)| pair[k.to_sym] = v; pair}) if keyed_message[:dt]
      keyed_message
    end

    def get_sequence_number_for_response sequence_number
      sequence_number + 1
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

    def send_response type, sequence_number
      agent.send_message({type: type, sequence_number: sequence_number })
    end
  end
end