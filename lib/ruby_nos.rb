require "ruby_nos/version"

module RubyNos
  autoload :Message,          "ruby_nos/message"
  autoload :UDPSender,        "ruby_nos/udp_sender"
  autoload :Agent,            "ruby_nos/agent"
  autoload :Cloud,            "ruby_nos/cloud"
  autoload :AgentsCollection, "ruby_nos/agents_collection"
  autoload :Initializable,    "initializable"
  autoload :Processor,        "ruby_nos/processor"
  autoload :Config,           "ruby_nos/config"
  autoload :VERSION,           "ruby_nos/version"
end
