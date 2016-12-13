require "spec_helper"

RSpec.describe Transactions::Order::CredentialAssigner, type: :job do
  let(:event) { create(:event) }
  let(:worker) { Transactions::Order::CredentialAssigner }
  let(:gtag) { create(:gtag, tag_uid: "FOOBARBAZ", event: event) }
  let(:customer) { create(:customer) }
  let(:atts) do
    {
      event_id: event.id,
      customer_tag_uid: gtag.tag_uid,
      customer_id: customer.id
    }
  end

  it "creates a credential for the gtag" do
    expect do
      worker.perform_later(atts)
      gtag.reload
    end.to change(gtag, :customer)
  end

  it "leaves the current customer if one present" do
    gtag.update!(customer: customer)
    expect do
      worker.perform_later(atts)
      gtag.reload
    end.not_to change(gtag, :customer)
  end
end
