module RubyNos
  class Processor

    attr_accessor :agent, :current_message

    def initialize agent
      @agent = agent
    end

    def formatter
      @formatter ||= Formatter.new
    end

    def signature_generator
      @signature_generator ||= SignatureGenerator.new
    end

    def process_message received_message
      formatted_message = formatter.parse_message(received_message)
      self.current_message = Message.new(formatted_message)

      unless sender_uuid == agent.uuid || !correct_signature?(formatted_message)
        RubyNos.logger.send(:info, "#{self.current_message.type} arrives")
        if agent_receptor? || cloud_receptor?
          processor = message_processor.fetch(current_message.type, nil)
          processor.call if processor
        end
      end
    end

    private

    def message_processor
      {
          "PIN" => lambda {process_pin_message},
          "PON" => lambda {process_pon_message},
          "PRS" => lambda {process_presence_message},
          "DSC" => lambda {process_discovery_message},
          "ENQ" => lambda {process_enquiry_message},
          "QNE" => lambda {process_enquiry_answer_message}
      }
    end

    def sender_uuid
      get_uuid(self.current_message.from)
    end

    def receptor_uuid
      get_uuid(self.current_message.to)
    end

    def received_api
      RestApi.new({name: self.current_message.data[:name]}).tap do |api|
        if self.current_message.data[:apis]
          self.current_message.data[:apis].each do |endpoint|
            api.add_endpoint(endpoint)
          end
        end
      end
    end

    def correct_signature? received_message
      if received_message[:sg]
        signature = received_message.delete(:sg)
        signature_generator.valid_signature?(received_message.to_s, signature)
      else
        true
      end
    end

    def process_pin_message
      update_cloud
      send_response "PON"
    end

    def process_pon_message
      update_cloud
    end

    def process_presence_message
      if self.current_message.data[:present] == 0
        agent.cloud.list.eliminate(sender_uuid)
      else
        update_cloud
      end
    end

    def process_discovery_message
      unless agent.cloud.list.is_on_the_list?(sender_uuid)
        update_cloud
      end
      send_response "PRS"
    end

    def process_enquiry_message
      update_cloud
      send_response "QNE"
    end

    def process_enquiry_answer_message
      agent.cloud.update(RemoteAgent.new({uuid: sender_uuid, timestamp: self.current_message.timestamp, rest_api: received_api}))
    end

    def update_cloud
      agent.cloud.update({agent_uuid: sender_uuid, info: self.current_message.data, timestamp: self.current_message.timestamp}) unless agent.cloud.uuid == sender_uuid
    end

    def agent_receptor?
      agent.uuid == receptor_uuid
    end

    def cloud_receptor?
      agent.cloud.uuid == receptor_uuid
    end

    def get_uuid uuid_param
      if uuid_param.start_with?("AGT:", "CLD:")
        uuid = formatter.convert_to_uuid(uuid_param[4..-1])
        if formatter.uuid_format?(uuid)
          uuid
        else
          raise(ArgumentError, 'Argument format is incorrect')
        end
      else
        raise(ArgumentError, 'Argument format is incorrect')
      end
    end

    def send_response type
      agent.send_message({type: type})
    end
  end
end
