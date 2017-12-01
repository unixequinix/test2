require "rails_helper"

RSpec.describe Transactions::Order::OrderRedeemer, type: :job do
  let(:event) { create(:event) }
  let(:worker) { Transactions::Order::OrderRedeemer.new }
  let(:customer) { create(:customer, event: event) }
  let(:catalog_item) { event.credit }
  let(:order) { create(:order, customer: customer, event: event) }
  let(:order_item) { create(:order_item, order: order, catalog_item: catalog_item, counter: 1) }
  let(:transaction) { create(:order_transaction, event: event, order: order, order_item_counter: order_item.counter) }
  let(:atts) { { customer_id: customer.id } }


  it "redeems the online order" do
    expect { worker.perform(transaction, atts) }.to change { order_item.reload.order.redeemed? }.from(false).to(true)
  end

  it "creates alert ir order is redeemed twice" do
    order_item.update(redeemed: true)
    expect(Alert).to receive(:propagate).once
    worker.perform(transaction, atts)
  end

  it "touches the customer after redeeming" do
    expect { worker.perform(transaction, atts) }.to change(customer.reload, :updated_at)
  end
end
