require "rails_helper"

RSpec.describe Jobs::Order::CredentialAssigner, type: :job do
  let(:worker) { Jobs::Order::CredentialAssigner }
  let(:gtag) { create(:gtag, tag_uid: "FOOBARBAZ") }
  let(:profile) { create(:customer_event_profile) }
  let(:atts) do
    {
      customer_tag_uid: gtag.tag_uid,
      customer_event_profile_id: profile.id
    }
  end

  %w( customer_tag_uid customer_event_profile_id ).each do |att|
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
    gtag.create_assigned_gtag_credential!(customer_event_profile: profile)
    expect do
      worker.perform_later(atts)
      gtag.reload
    end.not_to change(gtag, :assigned_gtag_credential)
  end
end
