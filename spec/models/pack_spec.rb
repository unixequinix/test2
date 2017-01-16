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

RSpec.describe Pack, type: :model do
  let(:pack) { create(:pack) }
  let(:credit) { create(:credit, event: pack.event) }
  let(:access) { create(:access, event: pack.event) }

  context "with credits" do
    before(:each) { pack.pack_catalog_items.create! catalog_item: credit, amount: 175 }

    it "returns the sum of all credit amounts" do
      pack.pack_catalog_items.create! catalog_item: credit, amount: 175
      expect(pack.reload.credits).to eq(350)
    end

    it "ignores the amounts of other types of catalog items" do
      pack.pack_catalog_items.create! catalog_item: access, amount: 1
      expect(pack.reload.credits).to eq(175)
    end

    it "is only_credits_pack if pack consists only of credits" do
      expect(pack.reload).to be_only_credits
    end

    it " is not only_credits_pack if other items are present" do
      pack.pack_catalog_items.create! catalog_item: access, amount: 1
      expect(pack.reload).not_to be_only_credits
    end
  end

  describe ".credits" do
    it "returns the sum amount of credits inside a pack" do
      pack.pack_catalog_items.create! catalog_item: credit, amount: 100
      pack.pack_catalog_items.create! catalog_item: credit, amount: 75
      expect(pack.credits).to eq(175)
    end
  end

  describe ".only_infinite_items?" do
    it "returns true if all the pack_catalog_items are infinite" do
      pack.pack_catalog_items.create! catalog_item: access, amount: 1
      expect(pack.only_infinite_items?).to be_truthy
    end
  end

  describe ".only_credits?" do
    it "returns true if all the pack_catalog_items are infinite" do
      pack.pack_catalog_items.create! catalog_item: credit, amount: 10
      expect(pack.only_credits?).to be_truthy
    end
  end
end
