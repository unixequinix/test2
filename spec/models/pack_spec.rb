require "rails_helper"

RSpec.describe Pack, type: :model do
  let(:pack) { create(:pack, :with_credit) }
  let(:credit) { create(:credit, event: pack.event) }
  let(:access) { create(:access, event: pack.event) }

  context "with credits" do
    it "returns the sum of all credit amounts" do
      pack.pack_catalog_items.create! catalog_item: credit, amount: 175
      expect(pack.reload.credits).to eq(185)
    end

    it "ignores the amounts of other types of catalog items" do
      pack.pack_catalog_items.create! catalog_item: access, amount: 1
      expect(pack.reload.credits).to eq(10)
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
      expect(pack.credits).to eq(185)
    end
  end

  describe ".only_infinite_items?" do
    it "returns true if all the pack_catalog_items are infinite" do
      pack.pack_catalog_items.clear
      pack.pack_catalog_items.create! catalog_item: access, amount: 1
      expect(pack.only_infinite_items?).to be_truthy
    end

    it "returns false if not all the pack_catalog_items are infinite" do
      pack.pack_catalog_items.create! catalog_item: access, amount: 1
      expect(pack.only_infinite_items?).to be_falsey
    end
  end

  describe ".only_credits?" do
    it "returns true if all the pack_catalog_items are credits" do
      expect(pack.only_credits?).to be_truthy
    end

    it "returns false if not all the pack_catalog_items are credits" do
      pack.pack_catalog_items.create! catalog_item: access, amount: 1
      expect(pack.only_credits?).to be_falsey
    end
  end
end
