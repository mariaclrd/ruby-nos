module RubyNos
  class RemoteAgent
    include Initializable
    attr_accessor :uuid, :sequence_number, :rest_api, :endpoints, :timestamp

    def endpoints
      @endpoints ||= []
    end

    def add_endpoint *args
      endpoints << Endpoint.new(*args)
    end

    def endpoints_collection
      endpoints.map{|e| e.to_hash}
    end

    def same_timestamp? another_agent
      timestamp == another_agent.timestamp
    end

    def same_endpoints? another_agent
      endpoints_collection == another_agent.endpoints_collection
    end

    def same_api? another_agent
      rest_api.to_hash == another_agent.rest_api.to_hash
    end
  end
end