# == Schema Information
#
# Table name: order_items
#
#  amount          :decimal(8, 2)
#  counter         :integer
#  redeemed        :boolean
#  total           :decimal(8, 2)    not null
#
# Indexes
#
#  index_order_items_on_catalog_item_id  (catalog_item_id)
#  index_order_items_on_order_id         (order_id)
#
# Foreign Keys
#
#  fk_rails_d59832cd1f  (catalog_item_id => catalog_items.id)
#  fk_rails_e3cb28f071  (order_id => orders.id)
#

require "spec_helper"

RSpec.describe OrderItem, type: :model do
  subject { build(:order_item) }

  describe ".single_credits?" do
    it "returns true if the catalog_item is a credit" do
      subject.catalog_item = build(:credit)
      expect(subject).to be_single_credits
    end
  end

  describe ".pack_with_credits?" do
    it "returns true if the catalog_item is a pack and has credits" do
      subject.catalog_item = build(:pack, :with_credit)
      allow(subject.catalog_item).to receive(:credits).and_return(20)
      expect(subject).to be_pack_with_credits
    end
  end

  describe ".credits" do
    it "returns the credits of the order_item" do
      subject.catalog_item = build(:credit)
      subject.amount = 50
      expect(subject.credits).to eq(50)
    end
  end

  describe ".refundable_credits" do
    context "when catalog_item is not a pack" do
      it "returns credits" do
        subject.catalog_item = build(:credit)
        subject.amount = 99
        expect(subject.refundable_credits).to eq(subject.credits)
      end
    end

    context "when catalog_item is a pack" do
      it "returns 0 if the pack has accesses" do
        pack = build(:full_pack)
        subject.catalog_item = pack
        allow(pack).to receive(:only_credits?).and_return(false)
        expect(subject.refundable_credits).to eq(0)
      end

      it "returns only the credits paid for at their standard price" do
        pack = create(:pack)
        credit = create(:credit, event: pack.event, value: 5)
        pack.pack_catalog_items.create(catalog_item: credit, amount: 10)
        order_item = create(:order_item, total: 20, catalog_item: pack.reload, counter: 1)
        expect(order_item.refundable_credits).to eq(4)
      end
    end
  end
end
