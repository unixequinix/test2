require "spec_helper"

RSpec.describe CreditTransaction, type: :model do
  it "can create sale_items with nested attributes" do
    items = %w[25 9 11].map { |n| { product_id: create(:product).id, quantity: n, unit_price: 2.72 } }
    params = { action: "sale", event: create(:event), transaction_origin: "portal", device_created_at: Time.zone.now }
    expect do
      CreditTransaction.create!(params.merge(sale_items_attributes: items))
    end.to change(SaleItem, :count).by(items.size)
  end
end
