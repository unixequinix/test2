require "rails_helper"

RSpec.describe Pack, type: :model do
  describe ".only_credits_pack?" do
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

      create(:pack_catalog_item,
                pack: pack,
                catalog_item: deep_pack.catalog_item,
                amount: 5)

      expect(pack.only_credits_pack?).to eq(true)
    end

    it "should return false if it doesn't have any credit inside " do
      pack = create(:pack, :with_access)
      expect(pack.only_credits_pack?).to eq(false)

      pack = create(:pack, :with_access, :with_credit)
      expect(pack.only_credits_pack?).to eq(false)

      pack = create(:pack, :with_credit, :with_credit)
      deep_pack = create(:pack, :with_credit, :with_access)

      create(:pack_catalog_item,
                pack: pack,
                catalog_item: deep_pack.catalog_item,
                amount: 5)

      expect(pack.only_credits_pack?).to eq(false)
    end
  end
end

