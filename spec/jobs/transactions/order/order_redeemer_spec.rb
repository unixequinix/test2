require "rails_helper"

RSpec.describe Transactions::Order::OrderRedeemer, type: :job do
  let(:event) { create(:event) }
  let(:worker) { Transactions::Order::OrderRedeemer }
  let(:profile) { create(:profile) }
  let(:gtag) { create(:gtag, tag_uid: "FOOBARBAZ", event: event, profile: profile) }
  let(:catalog_item) { event.credits.standard.catalog_item }
  let(:customer_order) { create(:customer_order, profile: profile, catalog_item: catalog_item) }
  let(:atts) do
    {
      event_id: event.id,
      customer_tag_uid: gtag.tag_uid,
      profile_id: profile.id,
      catalogable_id: catalog_item.catalogable_id,
      catalogable_type: catalog_item.catalogable_type,
      customer_order_id: customer_order.counter,
      activation_counter: 1
    }
  end

  it "reedems the online order" do
    expect do
      worker.perform_later(atts)
      customer_order.reload
    end.to change(customer_order, :redeemed).from(false).to(true)
  end
end
