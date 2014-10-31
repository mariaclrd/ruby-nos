require "json"

module RubyNos
  class Processor

    attr_accessor :agents_collection

    def agents_collection
      @agents_collection ||= AgentsCollection.new
    end

    def process_message message
      message = parsed_message(message)

      if message[:ty] == "PIN"
        if (agents = agents_collection.for_agent_uuid(message[:to]).to_a) != []
          agents.first.send_message({type: "PON", to: message[:fr]})
        end
      end
    end

    private

    def parsed_message message
      parsed_message = JSON.parse(message)
      parsed_message.inject({}){|pair,(k,v)| pair[k.to_sym] = v; pair}
    end
  end
end