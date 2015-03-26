require "ruby_nos/version"

module RubyNos
  autoload :Agent,               "ruby_nos/agent"
  autoload :Cloud,               "ruby_nos/cloud"
  autoload :Initializable,       "initializable"
  autoload :ListforAgents,       "ruby_nos/list_for_agents"
  autoload :Message,             "ruby_nos/message"
  autoload :Processor,           "ruby_nos/processor"
  autoload :ResponsePendingList, "ruby_nos/response_pending_list"
  autoload :Formatter,           "ruby_nos/formatter"
  autoload :UDPReceptor,         "ruby_nos/udp_receptor"
  autoload :UDPSender,           "ruby_nos/udp_sender"
  autoload :VERSION,             "ruby_nos/version"
end
