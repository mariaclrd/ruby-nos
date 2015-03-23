module RubyNos
  class Agent
    include Initializable
    attr_accessor :uuid, :cloud, :pending_response_list, :udp_tx, :udp_rx, :cloud_uuid, :processor, :port

    def uuid
      @uuid ||= SecureRandom.uuid.gsub("-", "")
    end

    def udp_tx
      @udp_tx ||= UDPSender.new
    end

    def udp_rx
      @udp_rx ||= UDPReceptor.new(port)
    end

    def cloud
      @cloud      ||= Cloud.new(uuid: "000000000000006f00000000000000de")
    end

    def processor
      @processor ||= Processor.new(self)
    end

    def pending_response_list
      @pending_response_list ||= ResponsePendingList.new
    end

    def configure
      listen
      join_cloud
      send_connection_messages
    end

    def send_message args={}
      message = build_message(args)
      #puts "#{message[:ty]} sent"
      udp_tx.send({host: args[:host], port: args[:port], message: message})
      message
    end

    private

    def send_connection_messages
      begin
      thread = Thread.new do
        i = 0
        loop do
          i = i+1
          puts "Iteration number #{i}"
          puts "Agents on the cloud #{cloud.list_of_agents.count}"
          unless cloud.list_of_agents.empty?
            cloud.list_of_agents.each do |agent_uuid|
              if pending_response_list.is_on_the_list?(agent_uuid) && pending_response_list.count_for_agent(agent_uuid) == 3
                pending_response_list.eliminate_from_list(agent_uuid)
                puts "Agent #{agent_uuid} has been deleted from the list"
                cloud.eliminate_from_list(agent_uuid)
              else
                message = send_message({to: "AGT:#{agent_uuid}", type: "PIN"})
                pending_response_list.update(agent_uuid, message[:sq])
              end
            end
          end
          sleep 10
        end
      end
      thread
      rescue Exception => e
        puts "Error executing the thread #{e.message}"
      end
    end


    def build_message args
      if args[:type] == "PRS"
        data = receptor_info
      end

      if data
        Message.new({from: "AGT:#{uuid}", to: args[:to] || "CLD:#{cloud.uuid}", type: args[:type], sequence_number: args[:sequence_number], data: data}).serialize_with_optional_fields({options: [:dt]})
      else
        Message.new({from: "AGT:#{uuid}", to: args[:to] || "CLD:#{cloud.uuid}", type: args[:type], sequence_number: args[:sequence_number]}).serialize_message
      end
    end


    def receptor_info
      {present: 1, endpoints: ["UDP,#{udp_rx.socket.connect_address.ip_port},#{udp_rx.socket.connect_address.ip_address}"]}
    end

    def listen
      udp_rx.listen(processor)
    end

    def join_cloud
      send_message({type: 'DSC'})
    end
  end
end