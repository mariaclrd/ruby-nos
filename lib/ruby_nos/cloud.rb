require "securerandom"

module RubyNos
  class Cloud
    include Initializable
    attr_accessor :uuid, :agents_list

    def agents_list
      @agents_list ||= []
    end

    def add_agent uuid
      agents_list << uuid
    end
  end
end