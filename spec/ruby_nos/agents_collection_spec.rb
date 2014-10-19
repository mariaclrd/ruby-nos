require "spec_helper"

describe "RubyNos::AgentsCollection" do
  subject             {AgentsCollection.new(:db => db)}
  let(:subject_class) {AgentsCollection}
  let(:db)            {double('db', :where => [:agent_uuid => agent_uuid])}
  let(:query)         {double('query')}
  let(:entry)         {double('entry')}
  let(:agent_uuid)    {'abc'}
  let(:agent)         {Agent.new(:uuid => agent_uuid)}

  describe "for_agent_uuid" do

    it "returns the agent for a given uuid" do
      expect(db).to receive(:where).with(:agent_uuid => agent_uuid).and_return(query)
      allow(query).to receive(:map).and_yield(entry)
      expect_any_instance_of(subject_class).to receive(:build_from_entry).with(entry).and_return(agent)
      subject.for_agent_uuid(agent_uuid).to_a
    end

    it "converts the entry to an agent object" do
      expect(db).to receive(:where).with(:agent_uuid => agent_uuid).and_return(query)
      allow(query).to receive(:map).and_yield(entry)
      expect_any_instance_of(subject_class).to receive(:build_from_entry).with(entry).and_return(agent)
      expect(subject.for_agent_uuid(agent_uuid).to_a).to be_an_instance_of(Agent)
    end
  end

  describe "#create" do

    it "creates a new Agent" do
      expect(subject).to receive(:save_to_db).with(kind_of(Agent)).and_return(true)
      subject.create({:agent_uuid => agent_uuid})
    end
  end

  describe "#update" do

    it "updates an Agent" do
      expect(db).to receive(:where).with(:agent_uuid => agent_uuid).and_return(db)
      expect(db).to receive(:update).with(:agent_uuid => agent_uuid)
      subject.update(agent)
    end
  end

  describe "#to_a" do
    it "returns an array of agents" do
      expect(subject.to_a.first).to be_a(Agent)
      expect(subject.to_a.first.uuid).to eq(agent_uuid)
    end
  end

  describe "#map" do
    it 'returns a mapped array with the selected Agent' do
      expect(subject.map).to be_a(Enumerator)
      expect(subject.map.first).to be_a(Agent)
      expect(subject.map.first.uuid).to eq(agent_uuid)
    end
  end

  describe "#agents_array" do
    it "returns an array of agents" do
      expect(subject.agents_array.first).to be_a(Agent)
      expect(subject.agents_array.first.uuid).to eq(agent_uuid)
    end
  end
end