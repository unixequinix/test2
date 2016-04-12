require "rails_helper"

RSpec.describe Sorters::PurchasesSorter, type: :domain_logic do
  describe "has methods to sort a collection of purchases" do
    let(:profile) { create(:customer_event_profile) }

    it ".sort should sort a collection of purchases by category and stores it in a hash " do
      create(:customer_order, customer_event_profile: profile,
                              catalog_item: create(:access_catalog_item))
      create(:customer_order, customer_event_profile: profile,
                              catalog_item: create(:voucher_catalog_item))

      sorted_purchases = Sorters::PurchasesSorter.new(profile.purchases).sort(format: :hash)
      expect(sorted_purchases).to be_an_instance_of(Hash)
      expect(sorted_purchases.keys).to eq(%w(Voucher Access))
      expect(sorted_purchases.count).to eq(2)
    end
  end
end
