require 'yaml'

module RubyNos
  class Config

    def self.configure_database
      environment = 'database'
      dbconfig    = YAML.load(File.read('config/application.yml'))
      @database   = Sequel.connect(dbconfig[environment])
    end
  end
end