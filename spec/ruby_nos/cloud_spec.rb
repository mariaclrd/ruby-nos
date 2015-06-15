require "spec_helper"

describe "#RubyNos::Cloud" do
  subject{Cloud.new(uuid:cloud_uuid)}
  let(:cloud_uuid) {"122445"}
  let(:agent_uuid) {"12345"}
  let(:list) {double("list")}


  before do
    subject.list = list
  end

  describe "#update" do

    describe "new agent" do
      before do
        allow(list).to receive(:is_on_the_list?).with(agent_uuid).and_return(false)
      end

      context "receiving a Hash" do
        let(:agent_info) {{agent_uuid: agent_uuid, info: info}}
        let(:info)       {{:endpoints => ["UDP,something,something"]}}

        it "builds a RemoteAgent and stores it on the list" do
          expect(list).to receive(:add).with(an_instance_of(RemoteAgent))
          subject.update(agent_info)
        end
      end

      context "receiving a RemoteAgent" do
        let(:agent) {instance_double(RemoteAgent, uuid: agent_uuid, timestamp: 1, endpoints: [], rest_api: nil)}

        it "stores agents information if it is new" do
          expect(list).to receive(:add).with(agent)
          subject.update(agent)
        end
      end

    end

    describe "old agent" do
      let(:agent) {instance_double(RemoteAgent, uuid: agent_uuid, timestamp: 1, endpoints: [], rest_api: nil)}

      before(:each) do
        allow(list).to receive(:is_on_the_list?).with(agent_uuid).and_return(true)
        allow(list).to receive(:info_for).with(agent_uuid).and_return(agent)
      end

      context "agent updated with correct information" do
        let(:agent_updated) {instance_double(RemoteAgent, uuid: agent_uuid,  timestamp: 2, endpoints: ["something"], rest_api: nil)}

        it "if the agent exists and the information is not the same it updates to this new information" do
          expect(subject).to receive(:correct_timestamp?).and_return(true)
          expect(agent).to receive(:same_endpoints?).with(agent_updated).and_return(false)
          expect(list).to receive(:update).with(agent_uuid, agent_updated)
          subject.update(agent_updated)
        end
      end

      context "agent updating with the same information" do
        let(:agent) {instance_double(RemoteAgent, uuid: agent_uuid, timestamp: 1, endpoints: ["something"], rest_api: nil)}
        let(:agent_updated) {instance_double(RemoteAgent, uuid: agent_uuid, timestamp: 2, endpoints: ["something"], rest_api: nil)}

        it "if the agent exists and the information is not the same it updates to this new information" do
          expect(subject).to receive(:correct_timestamp?).and_return(true)
          expect(agent).to receive(:same_endpoints?).with(agent_updated).and_return(true)
          expect(agent).to receive(:same_api?).with(agent_updated).and_return(true)
          expect(agent).to receive(:same_timestamp?).with(agent_updated).and_return(true)
          expect(list).to_not receive(:update).with(agent_uuid, agent_updated)
          subject.update(agent_updated)
        end
      end


      context "agent updated with nil information" do
        context "nil endpoints" do
          let(:agent) {instance_double(RemoteAgent, uuid: agent_uuid, timestamp: 1, endpoints: ["something"], rest_api: nil)}
          let(:agent_updated) {instance_double(RemoteAgent, uuid: agent_uuid, timestamp: 2, endpoints: [], rest_api: nil)}

          it "only overwrite the entry with the new information" do
            expect(subject).to receive(:correct_timestamp?).and_return(true)
            expect(agent).to receive(:same_endpoints?).with(agent_updated).and_return(false)
            expect(agent_updated).to receive(:endpoints=).with(agent.endpoints)
            expect(list).to receive(:update).with(agent_uuid, agent_updated)
            subject.update(agent_updated)
          end
        end

        context "nil api" do
          let(:agent) {instance_double(RemoteAgent, uuid: agent_uuid, timestamp: 1, endpoints: ["something"], rest_api: double("rest_api"))}
          let(:agent_updated) {instance_double(RemoteAgent, uuid: agent_uuid, timestamp: 2, endpoints: ["something"], rest_api: nil)}

          it "only overwrite the entry with the new information" do
            expect(subject).to receive(:correct_timestamp?).and_return(true)
            expect(agent).to receive(:same_endpoints?).with(agent_updated).and_return(true)
            expect(agent).to receive(:same_api?).and_return(false)
            expect(agent_updated).to receive(:rest_api=).with(agent.rest_api)
            expect(list).to receive(:update).with(agent_uuid, agent_updated)
            subject.update(agent_updated)
          end
        end

      end
    end
  end
end
