require "spec_helper"

describe "#RubyNos::ResponsePendingList" do
   subject{ResponsePendingList.new}
   let(:agent_uuid)      {"12345"}
   let(:sequence_number) {1}
   let(:info)            {{sequence_numbers:[sequence_number],count:1}}

  describe "#eliminate_from_list" do
    it "delete a pending message from the list" do
      subject.update(agent_uuid, sequence_number)
      subject.eliminate_from_list(agent_uuid)
      expect(subject.response_pending_list).to eq([])
    end
  end

  describe "#response_pending_info" do
    it "extracts all the info of pending response from the list" do
      subject.update(agent_uuid, sequence_number)
      expect(subject.response_pending_info(agent_uuid)).to eq(info)
    end
  end

  describe "#update" do
    it "adds a message pending of a response if is not on the list" do
      subject.update(agent_uuid, sequence_number)
      expect(subject.response_pending_list).to eq([{agent_uuid => info}])
    end

    it "update the information on the list of a pending response" do
      subject.update(agent_uuid, sequence_number)
      subject.update(agent_uuid, sequence_number+1)
      expect(subject.response_pending_list).to eq([{agent_uuid => {sequence_numbers:[sequence_number, sequence_number+1],count:2} }])
    end
  end

  describe "#is_on_the_list?" do
    it "returns true if there is any entry on the list " do
      subject.update(agent_uuid, sequence_number)
      expect(subject.is_on_the_list?(agent_uuid)).to eq(true)
    end
  end
end