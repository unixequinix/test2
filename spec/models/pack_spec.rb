require "rails_helper"

RSpec.describe Pack, type: :model do
  describe ".only_credits_pack?" do
    it "should return the credits inside a pack grouped by their name (credits in packs)" do
      credit_a = create(:credit, value: 2, currency: "EUR", standard: false)
      catalog_item_with_pack = create(:catalog_item, :with_empty_pack)
      pack_nested = catalog_item_with_pack.catalogable
      create(:pack_catalog_item, pack: pack_nested, catalog_item: credit_a.catalog_item, amount: 30.0)

      credit_b = create(:credit, value: 3, currency: "EUR", standard: false)
      catalog_item_with_pack = create(:catalog_item, :with_empty_pack)
      pack = catalog_item_with_pack.catalogable
      create(:pack_catalog_item, pack: pack, catalog_item: credit_b.catalog_item, amount: 40.0)
      create(:pack_catalog_item, pack: pack, catalog_item: pack_nested.catalog_item, amount: 10.0)

      expect(pack.credits.count).to eq(2)
      credits_array = pack.credits.sort_by(&:total_amount)

      enriched_credit_a = credits_array.first
      expect(enriched_credit_a.catalog_item_id).not_to be_nil
      expect(enriched_credit_a.total_amount.to_f).to be(40.0)

      enriched_credit_b = credits_array.second
      expect(enriched_credit_b.catalog_item_id).not_to be_nil
      expect(enriched_credit_b.total_amount.to_f).to be(300.0)
    end

    it "should return true if it has a single credit inside " do
      pack = create(:pack, :with_credit)
      expect(pack.only_credits_pack?).to eq(true)
    end

    it "should return true if it has multiple credits inside " do
      pack = create(:pack, :with_credit, :with_credit)
      expect(pack.only_credits_pack?).to eq(true)
    end

    it "should return true if it has credits and all the nested packs also have only credits" do
      pack = create(:pack, :with_credit, :with_credit)
      deep_pack = create(:pack, :with_credit)
      create(:pack_catalog_item, pack: pack, catalog_item: deep_pack.catalog_item, amount: 5.0)
      expect(pack.only_credits_pack?).to eq(true)
    end

    it "should return false if it doesn't have any credit inside (1 item inside) " do
      pack = create(:pack, :with_access)
      expect(pack.only_credits_pack?).to eq(false)
    end

    it "should return false if it doesn't have any credit inside (2 items inside)" do
      pack = create(:pack, :with_access, :with_credit)
      expect(pack.only_credits_pack?).to eq(false)
    end

    it "should return false if it doesn't have any credit inside (1 item and 1 pack inside)" do
      pack = create(:pack, :with_credit, :with_credit)
      deep_pack = create(:pack, :with_credit, :with_access)
      pack.pack_catalog_items.create!(catalog_item: deep_pack.catalog_item, amount: 5.0)
      expect(pack.only_credits_pack?).to eq(false)
    end
  end

  describe ".credits?" do
    it "should return the credits inside a pack grouped by their name (same credit)" do
      credit_a = create(:credit, value: 2, currency: "EUR", standard: false)
      catalog_item_with_pack = create(:catalog_item, :with_empty_pack)
      pack = catalog_item_with_pack.catalogable

      create(:pack_catalog_item, pack: pack, catalog_item: credit_a.catalog_item, amount: 30.0)
      create(:pack_catalog_item, pack: pack, catalog_item: credit_a.catalog_item, amount: 40.0)

      expect(pack.credits.count).to eq(1)

      enriched_credit = pack.credits.first
      expect(enriched_credit.catalog_item_id).not_to be_nil
      expect(enriched_credit.total_amount.to_f).to be(70.0)
    end

    it "should return the credits inside a pack grouped by their name (different credits)" do
      credit_a = create(:credit, value: 2, currency: "EUR", standard: false)
      credit_b = create(:credit, value: 3, currency: "EUR", standard: false)
      catalog_item_with_pack = create(:catalog_item, :with_empty_pack)
      pack = catalog_item_with_pack.catalogable

      create(:pack_catalog_item, pack: pack, catalog_item: credit_a.catalog_item, amount: 30.0)
      create(:pack_catalog_item, pack: pack, catalog_item: credit_b.catalog_item, amount: 40.0)

      expect(pack.credits.count).to eq(2)
      credits_array = pack.credits.sort_by(&:total_amount)

      enriched_first_credit = credits_array.first
      expect(enriched_first_credit.catalog_item_id).not_to be_nil
      expect(enriched_first_credit.total_amount.to_f).to be(30.0)

      enriched_second_credit = credits_array.second
      expect(enriched_second_credit.catalog_item_id).not_to be_nil
      expect(enriched_second_credit.total_amount.to_f).to be(40.0)
    end
  end
end
