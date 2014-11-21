require "spec_helper"

describe "#RubyNos::Cloud" do
  subject{Cloud.new(uuid:cloud_uuid)}
  let(:cloud_uuid) {"122445"}

  describe "#join" do
    let(:uuid) {"12345"}
    it "adds an agent to the agents_list" do
      subject.add_agent(uuid)
      expect(subject.agents_list.count).to eq(1)
    end
  end
end
