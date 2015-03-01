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

      unless get_from_uuid(message[:fr]) == agent.uuid
        puts "#{message[:ty]} arrives"
        if message[:ty] == "PIN"
          process_pin_message(message)
        else
          if cloud_receptor?(message[:to])
            if message[:ty] == "PON"
              process_pon_message(message)
            elsif message[:ty] == "PRS"
              process_presence_message(message)
            elsif message[:ty] == "DSC"
              process_discovery_message(message)
            end
          end
        end
      end
    end

    private

    def process_pin_message message
      if agent_receptor?(message[:to])
        sequence_number = get_sequence_number_for_response message[:sq]
        send_response "PON", sequence_number
      end
    end

    def process_pon_message message
      sender_uuid = get_from_uuid(message[:fr])
      if agent.pending_response_list.is_on_the_list?(sender_uuid)
        check_sequence_number(sender_uuid, message[:sq])
      end
      agent.cloud.update(sender_uuid, message[:dt])
    end

    def process_presence_message message
      agent.cloud.update(get_from_uuid(message[:fr]), message[:dt])
    end

    def process_discovery_message message
      sequence_number = get_sequence_number_for_response message[:sq]
      send_response "PRS", sequence_number
    end

    def parsed_message message
      parsed_message = JSON.parse(message)
      keyed_message = parsed_message.inject({}){|pair,(k,v)| pair[k.to_sym] = v; pair}
      (keyed_message[:dt] = keyed_message[:dt].inject({}){|pair,(k,v)| pair[k.to_sym] = v; pair}) if keyed_message[:dt]
      keyed_message
    end

    def get_sequence_number_for_response sequence_number
      sequence_number + 1
    end

    def check_sequence_number sender_uuid, sequence_number
      info = agent.pending_response_list.response_pending_info(sender_uuid)
      if info[:sequence_numbers].include?(sequence_number-1)
        agent.pending_response_list.eliminate_from_list(sender_uuid)
      end
    end

    def agent_receptor? to_param
      "ag:#{agent.uuid}" == to_param
    end

    def cloud_receptor? to_param
      "cd:#{agent.cloud.uuid}" == to_param
    end

    def get_from_uuid from_param
      if from_param.start_with?("ag:", "AG:")
        from_array = from_param.split("")
        for i in 0..2
          from_array.shift
        end
        from_array.join
      else
        from_param
      end
    end

    def send_response type, sequence_number
      agent.send_message({type: type, sequence_number: sequence_number })
    end
  end
end