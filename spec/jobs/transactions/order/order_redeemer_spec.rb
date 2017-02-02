require "spec_helper"

RSpec.describe Transactions::Order::OrderRedeemer, type: :job do
  let(:event) { create(:event) }
  let(:worker) { Transactions::Order::OrderRedeemer }
  let(:customer) { create(:customer) }
  let(:gtag) { create(:gtag, tag_uid: "FOOBARBAZ", event: event, customer: customer) }
  let(:catalog_item) { event.credit }
  let(:order) { create(:order, customer: customer) }
  let(:order_item) { create(:order_item, order: order, catalog_item: catalog_item, counter: 1) }
  let(:atts) do
    {
      event_id: event.id,
      customer_tag_uid: gtag.tag_uid,
      customer_id: customer.id,
      catalog_item_id: catalog_item.id,
      order_item_counter: order_item.counter,
      activation_counter: 1,
      gtag_id: gtag.id
    }
  end

  it "reedems the online order" do
    expect do
      worker.perform_later(atts)
      order_item.reload
    end.to change(order_item, :redeemed).from(false).to(true)
  end
end
