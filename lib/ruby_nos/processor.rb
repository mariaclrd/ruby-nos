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
        if ("ag:#{agent.uuid}" == message[:to])
          agent.send_message({type: "PON", to: message[:fr]})
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