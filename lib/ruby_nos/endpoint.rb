module RubyNos
  class Endpoint
    include Initializable
    attr_accessor :path, :port, :sticky, :type, :priority, :host
    ALLOWED_TYPES = ["PUBLIC", "HEALTHCHECK", "INTERNAL", "MSNOS_HTTP", "UDP", "HTTP", "PUB", "HCK", "INT", "MHT"]
    alias :pa= :path=
    alias :po= :port=
    alias :st= :sticky=
    alias :ty= :type=
    alias :xp= :priority=
    alias :ho= :host=

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
          pa: self.path,
          po: self.port,
          st: self.sticky,
          ty: self.type,
          xp: self.priority,
          ho: self.host
      }
    end
  end
end