module RubyNos
  class Endpoint
    include Initializable
    attr_accessor :path, :port, :sticky, :type, :priority, :host
    ALLOWED_TYPES = ["PUBLIC", "HEALTHCHECK", "INTERNAL", "MSNOS_HTTP", "UDP", "HTTP"]

    def type= type
      if ALLOWED_TYPES.include?(type)
        @type = type
      else
        raise SyntaxError
      end
    end

    def priority
      @priority ||= 0
    end

    def sticky
      @sticky ||= 0
    end

    def to_hash
      {
          path: self.path,
          port: self.port,
          sticky: self.sticky,
          type: self.type,
          priority: self.priority,
          host: self.host
      }
    end
  end
end