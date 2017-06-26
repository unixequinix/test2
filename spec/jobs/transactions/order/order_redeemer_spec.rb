require "rails_helper"

RSpec.describe Transactions::Order::OrderRedeemer, type: :job do
  let(:event) { create(:event) }
  let(:transaction) { create(:order_transaction, event: event) }
  let(:worker) { Transactions::Order::OrderRedeemer }
  let(:customer) { create(:customer, event: event) }
  let(:catalog_item) { event.credit }
  let(:order) { create(:order, customer: customer) }
  let(:order_item) { create(:order_item, order: order, catalog_item: catalog_item, counter: 1) }
  let(:atts) do
    {
      event_id: event.id,
      customer_id: customer.id,
      order_item_counter: order_item.counter,
      transaction_id: transaction.id
    }
  end

  it "reedems the online order" do
    expect do
      worker.perform_later(atts)
      order_item.reload
    end.to change(order_item, :redeemed).from(false).to(true)
  end

  it "assigns the order to the transaction" do
    expect do
      worker.perform_later(atts)
      transaction.reload
    end.to change(transaction, :order_id).to(order.id)
  end

  it "doesnt assign the order to the transaction if already redeemed" do
    order_item.update(redeemed: true)
    expect do
      worker.perform_later(atts)
      transaction.reload
    end.not_to change(transaction, :order_id)
  end
end
