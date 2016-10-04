require "rails_helper"

RSpec.describe Operations::Order::CredentialAssigner, type: :job do
  let(:event) { create(:event) }
  let(:worker) { Operations::Order::CredentialAssigner }
  let(:gtag) { create(:gtag, tag_uid: "FOOBARBAZ", event: event) }
  let(:profile) { create(:profile) }
  let(:atts) do
    {
      event_id: event.id,
      customer_tag_uid: gtag.tag_uid,
      profile_id: profile.id
    }
  end

  %w( customer_tag_uid profile_id ).each do |att|
    it "requires #{att} as attribute" do
      atts.delete(att.to_sym)
      expect { worker.perform_later(atts) }.to raise_error
    end
  end

  it "creates a credential for the gtag" do
    expect do
      worker.perform_later(atts)
      gtag.reload
    end.to change(gtag, :assigned_gtag_credential)
  end

  it "leaves the current assigned_gtag_credential if one present" do
    gtag.create_assigned_gtag_credential!(profile: profile)
    expect do
      worker.perform_later(atts)
      gtag.reload
    end.not_to change(gtag, :assigned_gtag_credential)
  end
end
