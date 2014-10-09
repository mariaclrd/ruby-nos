require "securerandom"

module RubyNos
  class Cloud
    attr_accessor :uuid, :agents_list

    def initialize uuid
      @uuid ||= uuid
    end

    def agents_list
      @agents_list ||= []
    end

    def add_agent uuid
      agents_list << uuid
    end
  end
end