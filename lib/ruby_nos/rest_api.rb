module RubyNos
  class RestApi
    include Initializable
    attr_accessor :name, :endpoints, :port, :host

    def endpoints
      @endpoints ||= []
    end

    def add_endpoint args
      args.merge!({port: port}) unless (args[:port] || args[:po] )
      args.merge!({host: host}) unless (args[:host] || args[:ho] )
      endpoints << Endpoint.new(args)
    end

    def to_hash
      {
          name: self.name,
          apis: endpoints.map{|e| e.to_hash}
      }
    end
  end
end