require "spec_helper"

describe RubyNos::List do
  subject{List.new}
  let(:element) {double("element", uuid: "12345")}

  before do
    subject.add(element)
  end

  describe "#add" do
    it "adds an element to the list" do
      expect(subject.list.count).to eq(1)
      expect(subject.list.first).to eq({element.uuid => element})
    end
  end

  describe "#update" do
    let(:element_two) {double("another_element", uuid: "12345", some_other_thing: "something")}

    it "updates an element on the list that has the same uuid" do
      subject.update(element.uuid, element_two)
      expect(subject.list.count).to eq 1
      expect(subject.list.first[element_two.uuid].some_other_thing).to eq "something"
    end
  end

  describe "#eliminate" do
    it "eliminates an element from the list" do
      subject.eliminate(element.uuid)
      expect(subject.list.count).to eq 0
    end
  end

  describe "#info_for" do
    it "returns the information on the list for an element" do
      info = subject.info_for(element.uuid)
      expect(info.uuid).to eq("12345")
    end
  end

  describe "#list_of_keys" do
    it "returns the list of keys in the list" do
      expect(subject.list_of_keys).to eq(["12345"])
    end
  end

  describe "#is_on_the_list?" do
    it "returns true if the element exists and folder if it does not exist" do
      expect(subject.is_on_the_list?(element.uuid)).to eq(true)
      expect(subject.is_on_the_list?("some_uuid")).to eq(false)
    end
  end
end