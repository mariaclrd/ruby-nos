module RubyNos
  class RemoteAgent
    include Initializable
    attr_accessor :uuid, :sequence_number, :rest_api, :endpoints

    def endpoints
      @endpoints ||= []
    end

    def add_endpoint *args
      endpoints << Endpoint.new(*args)
    end
  end
end