require "rails_helper"

RSpec.describe Sorters::CatalogItemSorter, type: :domain_logic do
  describe "has methods to sort a collection of catalog items" do
    let(:event) { build_stubbed(:event) }
    let(:catalog_items_collection) do
      [
        instance_double("CatalogItem", id: 4, event_id: 1, catalogable_id: 3,
                                       catalogable_type: "Access", name: "Friday Pass",
                                       price: 30.0),
        instance_double("CatalogItem", id: 8, event_id: 1, catalogable_id: 3,
                                       catalogable_type: "Voucher", name: "Voucher C",
                                       price: 70.0),
        instance_double("CatalogItem", id: 1, event_id: 1, catalogable_id: 1,
                                       catalogable_type: "Credit", name: "Standard credit",
                                       price: 1.0),
        instance_double("CatalogItem", id: 12, event_id: 1, catalogable_id: 2,
                                       catalogable_type: "Credit", name: "Cheap Credit",
                                       price: 2.0),
        instance_double("CatalogItem", id: 3, event_id: 1, catalogable_id: 2,
                                       catalogable_type: "Access", name: "VIP Pass",
                                       price: 20.0),
        instance_double("CatalogItem", id: 7, event_id: 1, catalogable_id: 2,
                                       catalogable_type: "Voucher", name: "Voucher B",
                                       price: 60.0),
        instance_double("CatalogItem", id: 13, event_id: 1, catalogable_id: 4,
                                       catalogable_type: "Pack", name: "paker",
                                       price: 2.0)
      ]
    end

    it ".sort should sort a collection of catalog items by category and stores it in a hash " do
      sorted_items = Sorters::CatalogItemSorter.new(catalog_items_collection).sort(format: :hash)

      expect(sorted_items).to be_an_instance_of(Hash)
      expect(sorted_items.keys).to eq(%w(Credit Voucher Access Pack))
      expect(sorted_items["Credit"].first.id).to be(1)
      expect(sorted_items["Credit"].second.id).to be(12)
      expect(sorted_items["Voucher"].first.id).to be(7)
      expect(sorted_items["Voucher"].second.id).to be(8)
      expect(sorted_items["Access"].first.id).to be(3)
      expect(sorted_items["Access"].second.id).to be(4)
      expect(sorted_items["Pack"].first.id).to be(13)
    end

    it ".sort should sort a collection of catalog items by category and stores it in a list " do
      sorted_items = Sorters::CatalogItemSorter.new(catalog_items_collection).sort(format: :list)
      expect(sorted_items).to be_an_instance_of(Array)
      expect(sorted_items.count).to eq(7)
      expect(sorted_items.map(&:id)).to eq([1, 12, 7, 8, 3, 4, 13])
    end
  end
end
