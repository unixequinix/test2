require "rails_helper"

RSpec.describe Transactions::Order::OrderRedeemer, type: :job do
  let(:event) { create(:event) }
  let(:worker) { Transactions::Order::OrderRedeemer }
  let(:gtag) { create(:gtag, tag_uid: "FOOBARBAZ", event: event) }
  let(:profile) { create(:profile) }
  let(:catalog_item) { event.credits.standard.catalog_item }
  let(:customer_order) { create(:customer_order, profile: profile, catalog_item: catalog_item) }
  let(:online_order) { create(:online_order, customer_order: customer_order, redeemed: false) }
  let(:atts) do
    {
      event_id: event.id,
      customer_tag_uid: gtag.tag_uid,
      profile_id: profile.id,
      catalogable_id: catalog_item.catalogable_id,
      catalogable_type: catalog_item.catalogable_type,
      customer_order_id: online_order.counter
    }
  end

  before { create(:credential_assignment, profile: profile, credentiable: gtag) }
  it "reedems the online order" do
    expect do
      worker.perform_later(atts)
      online_order.reload
    end.to change(online_order, :redeemed).from(false).to(true)
  end
end
