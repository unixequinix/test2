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

RSpec.describe Pack, type: :model do
  let(:pack) { create(:pack) }
  let(:credit) { create(:credit, event: pack.event) }
  let(:access) { create(:access, event: pack.event) }

  context "with credits" do
    before(:each) { pack.pack_catalog_items.create! catalog_item: credit, pack: pack, amount: 175 }

    it "returns the sum of all credit amounts" do
      pack.pack_catalog_items.create! catalog_item: credit, pack: pack, amount: 175
      expect(pack.reload.credits).to eq(350)
    end

    it "ignores the amounts of other types of catalog items" do
      pack.pack_catalog_items.create! catalog_item: access, pack: pack, amount: 1
      expect(pack.reload.credits).to eq(175)
    end

    it "is only_credits_pack if pack consists only of credits" do
      expect(pack.reload).to be_only_credits
    end

    it " is not only_credits_pack if other items are present" do
      pack.pack_catalog_items.create! catalog_item: access, pack: pack, amount: 1
      expect(pack.reload).not_to be_only_credits
    end
  end
end
