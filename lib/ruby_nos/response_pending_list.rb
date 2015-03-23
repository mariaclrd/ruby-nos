module RubyNos
  class ResponsePendingList < ListforAgents
    include Initializable

    alias response_pending_list list

    def update agent_uuid, sequence_number
      if is_on_the_list?(agent_uuid)
        update_response_pending_info(agent_uuid, sequence_number)
      else
        add_to_response_pending_list(agent_uuid,sequence_number)
      end
    end

    def count_for_agent uuid
      info_on_the_list(uuid)[:count]
    end

    private

    def update_response_pending_info uuid, sequence_number
      pending_response = response_pending_list.select{|e| e[uuid]}.first[uuid]
      pending_response[:sequence_numbers] << sequence_number
      pending_response[:count] = pending_response[:count] + 1
    end

    def add_to_response_pending_list uuid, sequence_number
      response_pending_list << {uuid => {sequence_numbers: [sequence_number], count: 1} }
    end
  end
end