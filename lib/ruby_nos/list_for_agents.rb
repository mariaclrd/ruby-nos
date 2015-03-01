module RubyNos
  class ListforAgents
    include Initializable
    attr_accessor :list

    def list
      @list ||= []
    end

    def eliminate_from_list uuid
      list.delete_if{|e| e.keys.first == uuid}
    end

    def info_on_the_list uuid
      list.map{|e| e[uuid]}.first
    end

    def list_of_agents
      list.map{|e| e.keys}.flatten
    end

    def is_on_the_list? uuid
      list_of_agents.include?(uuid)
    end

  end
end