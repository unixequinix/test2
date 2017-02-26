# == Schema Information
#
# Table name: catalog_items
#
#  initial_amount  :integer
#  max_purchasable :integer
#  memory_length   :integer          default(1)
#  memory_position :integer
#  min_purchasable :integer
#  mode            :string
#  name            :string
#  step            :integer
#  type            :string           not null
#  value           :decimal(8, 2)    default(1.0), not null
#
# Indexes
#
#  index_catalog_items_on_event_id                      (event_id)
#  index_catalog_items_on_memory_position_and_event_id  (memory_position,event_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_6d2668d4ae  (event_id => events.id)
#

require "spec_helper"

RSpec.describe Access, type: :model do
  subject { build(:access, mode: "counter") }

  it "has a valid factory" do
    expect(subject).to be_valid
  end

  describe ".infinite?" do
    it "false for 'counter'" do
      allow(subject).to receive(:mode).and_return("counter")
      expect(subject.infinite?).to eq(false)
    end

    it "true for 'permanent'" do
      allow(subject).to receive(:mode).and_return("permanent")
      expect(subject.infinite?).to eq(true)
    end

    it "true for 'permanent_strict'" do
      allow(subject).to receive(:mode).and_return("permanent_strict")
      expect(subject.infinite?).to eq(true)
    end
  end

  context "before validations" do
    describe ".position " do
      it "adds the next memory_position to the new subject" do
        event = create(:event)
        create(:access, event: event)
        access = create(:access, event: event)
        expect(access.memory_position).to eq(3)
      end
    end
  end

  describe ".set_memory_length" do
    it "sets the subject memory_length to 2 " do
      subject.save!
      expect(subject.memory_length).to eq(2)
    end
  end
end
