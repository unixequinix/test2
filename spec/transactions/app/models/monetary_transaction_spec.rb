require "rails_helper"

RSpec.describe MonetaryTransaction, type: :model do
  let(:transaction) { build(:customer_credit) }

  it "expects to define methods for each subscription action" do
    transaction.class::SUBSCRIPTIONS.values.flatten.each do |action|
      expect(transaction).to respond_to(action)
    end
  end

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
