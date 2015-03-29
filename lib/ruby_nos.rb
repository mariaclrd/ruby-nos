require "ruby_nos/version"
require 'mini_logger'

module RubyNos
  autoload :Agent,               "ruby_nos/agent"
  autoload :Cloud,               "ruby_nos/cloud"
  autoload :Formatter,           "ruby_nos/formatter"
  autoload :Initializable,       "initializable"
  autoload :ListforAgents,       "ruby_nos/list_for_agents"
  autoload :Message,             "ruby_nos/message"
  autoload :Processor,           "ruby_nos/processor"
  autoload :ResponsePendingList, "ruby_nos/response_pending_list"
  autoload :SignatureGenerator,  "ruby_nos/signature_generator"
  autoload :UDPReceptor,         "ruby_nos/udp_receptor"
  autoload :UDPSender,           "ruby_nos/udp_sender"
  autoload :VERSION,             "ruby_nos/version"

  class << self
    include MiniLogger::Loggable

    attr_accessor :signature_key, :logger, :port, :cloud_uuid, :group_address

    def configure
      if block_given?
        yield self
        true
      end
    end

    def signature_key
      @signature_key ||= "key"
    end

    def logger
      @logger ||= Logger.new './log/application.log'
    end

    def port
      @port ||= 3784
    end

    def cloud_uuid
      @cloud_uuid ||= SecureRandom.uuid
    end

    def group_address
      @group_address ||= "230.31.32.33"
    end

  end
end
