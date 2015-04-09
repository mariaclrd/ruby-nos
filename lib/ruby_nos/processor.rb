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
        if current_message.type == "PIN"
          process_pin_message
        else
          if cloud_receptor?
            if current_message.type == "PON"
              process_pon_message
            elsif current_message.type == "PRS"
              process_presence_message
            elsif current_message.type == "DSC"
              process_discovery_message
            elsif current_message.type == "ENQ"
              process_enquiry_message
            elsif current_message.type == "QNE"
              process_enquiry_answer_message
            end
          end
        end
      end
    end

    private

    def sender_uuid
      get_uuid(self.current_message.from)
    end

    def receptor_uuid
      get_uuid(self.current_message.to)
    end

    def received_api
      api = RestApi.new({name: self.current_message.data[:name]})
      if self.current_message.data[:apis]
        self.current_message.data[:apis].each do |endpoint|
          api.add_endpoint(endpoint)
        end
      end
      api
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
      if agent_receptor?
        send_response "PON", get_sequence_number_for_response
      end
    end

    def process_pon_message
      update_cloud
    end

    def process_presence_message
      update_cloud
    end

    def process_discovery_message
      if !agent.cloud.is_on_the_list?(sender_uuid)
        update_cloud
      end
      send_response "PRS", get_sequence_number_for_response
    end

    def process_enquiry_message
      send_response "QNE", get_sequence_number_for_response
    end

    def process_enquiry_answer_message
      if agent.cloud.is_on_the_list?(sender_uuid)
        agent.cloud.info_on_the_list(sender_uuid).rest_api = received_api
      else
        agent.cloud.insert_new_remote_agent(RemoteAgent.new({uuid: sender_uuid, sequence_number: self.current_message.sequence_number, rest_api: received_api}))
      end
    end

    def update_cloud
      agent.cloud.update(sender_uuid, self.current_message.sequence_number, self.current_message.data)
    end

    def get_sequence_number_for_response
      self.current_message.sequence_number + 1
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

    def send_response type, sequence_number
      agent.send_message({type: type, sequence_number: sequence_number })
    end
  end
end