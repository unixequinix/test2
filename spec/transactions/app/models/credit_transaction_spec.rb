require "rails_helper"

RSpec.describe CreditTransaction, type: :model do
  it "can create transaction_items with nested attributes" do
    items = %w( 25 9 11 ).map { |n| { unit_price: n } }
    expect do
      CreditTransaction.create!(transaction_type: "sale", sale_items_attributes: items)
    end.to change(SaleItem, :count).by(items.size)
  end
end
