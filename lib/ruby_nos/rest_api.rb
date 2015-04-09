module RubyNos
  class RestApi
    include Initializable
    attr_accessor :name, :endpoints

    def endpoints
      @endpoints ||= []
    end

    def add_endpoint *args
       endpoints << Endpoint.new(*args)
    end

    def to_hash
      {
          name: self.name,
          apis: endpoints.map{|e| e.to_hash}
      }
    end
  end
end