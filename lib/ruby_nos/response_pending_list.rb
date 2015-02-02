module RubyNos
  class ResponsePendingList
    include Initializable

    attr_accessor :response_pending_list

    def response_pending_list
      @response_pending_list ||= []
    end

    def update agent_uuid, sequence_number
      if is_on_the_list?(agent_uuid)
        update_response_pending_info(agent_uuid, sequence_number)
      else
        add_to_response_pending_list(agent_uuid,sequence_number)
      end
    end

    def eliminate_from_list uuid
      response_pending_list.delete_if{|e| e.keys.first == uuid}
    end

    def response_pending_info uuid
      response_pending_list.map{|e| e[uuid]}.first
    end

    def is_on_the_list? uuid
      response_pending_list.map{|e| e.keys}.flatten.include?(uuid)
    end

    def count uuid
      response_pending_list.response_pending_info(uuid)[:count]
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