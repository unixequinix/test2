require "rails_helper"

RSpec.describe Sorters::PurchasesSorter, type: :domain_logic do
  describe "has methods to sort a collection of purchases" do
    let(:profile) { create(:profile) }

    it ".sort should sort a collection of simple purchases by category and stores it in a hash " do
      create(:customer_order, profile: profile,
                              catalog_item: create(:access_catalog_item))
      create(:customer_order, profile: profile,
                              catalog_item: create(:voucher_catalog_item))

      sorted_purchases = Sorters::PurchasesSorter.new(profile.purchases).sort(format: :hash)
      expect(sorted_purchases).to be_an_instance_of(Hash)
      expect(sorted_purchases.keys).to eq(%w(Voucher Access))
      expect(sorted_purchases.count).to eq(2)
      expect(sorted_purchases["Access"].count).to eq(1)
      expect(sorted_purchases["Voucher"].count).to eq(1)
    end

    it "with a pack, .sort should sort its inner items by category and stores it in a hash " do
      create(:customer_order, profile: profile,
                              catalog_item: create(:pack_item_catalog_item))
      sorted_purchases = Sorters::PurchasesSorter.new(profile.purchases).sort(format: :hash)
      expect(sorted_purchases).to be_an_instance_of(Hash)
      expect(sorted_purchases.keys).to eq(%w(Voucher Access))
      expect(sorted_purchases.count).to eq(2)
      expect(sorted_purchases["Access"].count).to eq(1)
      expect(sorted_purchases["Voucher"].count).to eq(1)
    end

    it ".sort should simple purchases and items inside a pack " do
      create(:customer_order, profile: profile,
                              catalog_item: create(:pack_item_catalog_item))
      create(:customer_order, profile: profile,
                              catalog_item: create(:voucher_catalog_item))
      create(:customer_order, profile: profile,
                              catalog_item: create(:access_catalog_item))
      sorted_purchases = Sorters::PurchasesSorter.new(profile.purchases).sort(format: :hash)
      expect(sorted_purchases).to be_an_instance_of(Hash)
      expect(sorted_purchases.keys).to eq(%w(Voucher Access))
      expect(sorted_purchases.count).to eq(2)
      expect(sorted_purchases["Access"].count).to eq(2)
      expect(sorted_purchases["Voucher"].count).to eq(2)
    end

    it ".sort should simple purchases and items inside a pack " do
      customer_order_a = create(:customer_order, profile: profile,
                                                 catalog_item: create(:voucher_catalog_item))
      customer_order_b = create(:customer_order, profile: profile,
                                                 catalog_item: customer_order_a.catalog_item)
      sorted_purchases = Sorters::PurchasesSorter.new(profile.purchases).sort(format: :hash)
      expect(sorted_purchases).to be_an_instance_of(Hash)
      expect(sorted_purchases.keys).to eq(%w(Voucher))
      expect(sorted_purchases.count).to eq(1)
      expect(sorted_purchases["Voucher"].count).to eq(1)
      expect(sorted_purchases["Voucher"].first.total_amount).to eq(
        customer_order_a.amount + customer_order_b.amount
      )
    end
  end
end
