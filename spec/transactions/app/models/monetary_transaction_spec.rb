require "rails_helper"

RSpec.describe MonetaryTransaction, type: :model do
  it "creates sale items from nested attributes" do
    params = { transaction_type: "sale",
               transaction_sale_items_attributes: [{
                 quantity: 9,
                 total_price_paid: 9.99
               }]
             }
    t = MonetaryTransaction.create(params)
    items = t.transaction_sale_items.where(params[:transaction_sale_items_attributes].first)
    expect(items).not_to be_empty
  end
end
