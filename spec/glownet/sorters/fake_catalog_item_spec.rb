require "rails_helper"

RSpec.describe Sorters::FakeCatalogItem, type: :domain_logic do
  describe "It is a version of CatalogItem with some extra fields" do
    let(:credit) do
      create(:credit_catalog_item)
    end

    let(:fake_catalog_item_a) do
      Sorters::FakeCatalogItem.new(catalog_item_id: credit.id,
                                   catalogable_id: credit.catalogable_id,
                                   catalogable_type: "Credit", product_name: "Standard credit",
                                   total_amount: 11, value: nil)
    end

    let(:fake_catalog_item_b) do
      Sorters::FakeCatalogItem.new(catalog_item_id: 6, catalogable_id: 1,
                                   catalogable_type: "Voucher", product_name: "Voucher A",
                                   total_amount: 1, value: nil)
    end

    let(:fake_catalog_items) do
      [Sorters::FakeCatalogItem.new(catalog_item_id: 6, catalogable_id: 1,
                                    catalogable_type: "Voucher", product_name: "Voucher A",
                                    total_amount: 1, value: nil),
       Sorters::FakeCatalogItem.new(catalog_item_id: 1, catalogable_id: 1,
                                    catalogable_type: "Credit", product_name: "Standard credit",
                                    total_amount: 11, value: nil)]
    end

    it ".eql? should return true if two FaceCatalogItems have the same catalog_item_id" do
      expect(fake_catalog_item_a.eql?(fake_catalog_item_a)).to eq(true)
      expect(fake_catalog_item_a.eql?(fake_catalog_item_b)).to eq(false)
    end

    it ".catalogable should return the catalogable item attached to the original Catalog Item" do
      expect(fake_catalog_item_a.catalogable).not_to eq(nil)
      expect(fake_catalog_item_a.catalogable.class.name).to eq("Credit")
    end
    it ".catalog_item should return the original Catalog Item" do
      expect(fake_catalog_item_a.catalog_item.eql?(credit)).to eq(true)
    end
  end
end
