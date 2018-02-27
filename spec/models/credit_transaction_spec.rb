require "rails_helper"

RSpec.describe CreditTransaction, type: :model do
  let(:event) { create(:event) }
  let(:payment) { [{ credit_id: event.credit.id, credit_name: event.credit.name, credit_value: event.credit.value.to_f, amount: 2.2 }] }
  let(:transaction) { create(:credit_transaction, action: "topup", event: event, payments: payment) }

  it "can create sale_items with nested attributes" do
    items = %w[25 9 11].map { |n| { product_id: create(:product).id, quantity: n, standard_unit_price: 2.72 } }
    params = { action: "sale", event: create(:event), transaction_origin: "portal", device_created_at: Time.zone.now }

    expect { CreditTransaction.create!(params.merge(sale_items_attributes: items)) }.to change(SaleItem, :count).by(items.size)
  end
end
