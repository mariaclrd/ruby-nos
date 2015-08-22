module RubyNos
  class List
    include Initializable
    attr_accessor :list

    def list
      @list ||= []
    end

    def add element
      list << {element.uuid => element}
    end
    
    def update uuid, new_element
      list.select{|e| e[uuid]}.first[uuid] = new_element
    end
      
    def eliminate uuid
      RubyNos.logger.send(:info, "Eliminated agent #{uuid}")
      list.delete_if{|e| e.keys.first == uuid}
    end

    def info_for uuid
      list.select{|e| e[uuid]}.first[uuid]
    end

    def list_of_keys
      list.map{|e| e.keys}.flatten
    end

    def is_on_the_list? uuid
      list_of_keys.include?(uuid)
    end
  end
end
