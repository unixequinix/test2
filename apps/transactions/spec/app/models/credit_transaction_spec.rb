require "spec_helper"

RSpec.describe CreditTransaction, type: :model do
  it "can create transaction_items with nested attributes" do
    items = [{ amount: 25 }, { quantity: 9 }, { amount: 11 }]
    expect do
      CreditTransaction.create!(transaction_type: "sale", transaction_items_attributes: items)
    end.to change(SaleItem, :count).by(items.size)
  end
end
