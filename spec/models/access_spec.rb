# == Schema Information
#
# Table name: catalog_items
#
#  created_at      :datetime         not null
#  initial_amount  :integer
#  max_purchasable :integer
#  min_purchasable :integer
#  name            :string
#  step            :integer
#  type            :string           not null
#  updated_at      :datetime         not null
#  value           :decimal(8, 2)    default(1.0), not null
#
# Indexes
#
#  index_catalog_items_on_event_id  (event_id)
#
# Foreign Keys
#
#  fk_rails_6d2668d4ae  (event_id => events.id)
#

require "spec_helper"

RSpec.describe Access, type: :model do
  subject { build(:access) }

  it "has a valid factory" do
    expect(subject).to be_valid
  end

  describe ".set_infinite_values" do
    it "sets propper values for permanent entitlements" do
      subject.entitlement = build(:entitlement, :permanent)
      subject.valid?
      expect(subject.min_purchasable).to eq(0)
      expect(subject.max_purchasable).to eq(1)
      expect(subject.step).to eq(1)
      expect(subject.initial_amount).to eq(0)
    end
  end

  describe ".set_memory_length" do
    it "sets the entitlement memory_length to 2 if the max purchasable is bigger than 7" do
      entitlement = build(:entitlement, :counter)
      subject.entitlement = entitlement
      subject.max_purchasable = 1
      subject.valid?
      expect(entitlement.memory_length).to eq(1)
      subject.max_purchasable = 10
      subject.valid?
      expect(entitlement.memory_length).to eq(2)
    end
  end

  describe ".min_max_congruency" do
    it "returns an error if the min purchasable is bigger than max purchasable" do
      subject.entitlement = build(:entitlement, :counter)
      expect(subject).to be_valid
      subject.max_purchasable = 10
      subject.min_purchasable = 20
      expect(subject).not_to be_valid
    end
  end
end
