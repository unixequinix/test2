require "rails_helper"

RSpec.describe CreditTransaction, type: :model do
  it "can create sale_items with nested attributes" do
    items = %w( 25 9 11 ).map do |n|
      {
        product_id: 5,
        quantity: n,
        unit_price: 2.72
      }
    end
    expect do
      CreditTransaction.create!(transaction_type: "sale", sale_items_attributes: items)
    end.to change(SaleItem, :count).by(items.size)
  end
end
