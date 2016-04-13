require "rails_helper"

RSpec.describe Operations::Order::CredentialAssigner, type: :job do
  let(:event) { create(:event) }
  let(:worker) { Operations::Order::CredentialAssigner }
  let(:gtag) { create(:gtag, tag_uid: "FOOBARBAZ", event: event) }
  let(:profile) { create(:customer_event_profile) }
  let(:atts) do
    {
      event_id: event.id,
      customer_tag_uid: gtag.tag_uid,
      customer_event_profile_id: profile.id
    }
  end

  it "works for real parameters" do
    params = {
      customer_event_profile_id: profile.id,
      customer_tag_uid: gtag.tag_uid,
      device_created_at: "2016-04-11T18:20:53",
      device_db_index: 1,
      device_uid: "485A3F720AC4",
      event_id: event.id,
      operator_tag_uid: "AAAAAAAAAAAAAA",
      station_id: 2,
      status_code: 0,
      status_message: nil,
      transaction_category: "order",
      transaction_origin: "onsite",
      transaction_type: "record_purchase",
      catalogable_id: 1,
      catalogable_type: "access",
      customer_order_id: nil
    }

    expect { worker.perform_later(params) }.not_to raise_error
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
