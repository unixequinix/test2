require "rails_helper"

RSpec.describe Transactions::Order::CredentialAssigner, type: :job do
  let(:event) { create(:event) }
  let(:worker) { Transactions::Order::CredentialAssigner }
  let(:gtag) { create(:gtag, tag_uid: "FOOBARBAZ", event: event) }
  let(:profile) { create(:profile) }
  let(:atts) do
    {
      event_id: event.id,
      customer_tag_uid: gtag.tag_uid,
      profile_id: profile.id
    }
  end

  it "creates a credential for the gtag" do
    expect do
      worker.perform_later(atts)
      gtag.reload
    end.to change(gtag, :profile)
  end

  it "leaves the current profile if one present" do
    gtag.update!(profile: profile)
    expect do
      worker.perform_later(atts)
      gtag.reload
    end.not_to change(gtag, :profile)
  end
end
