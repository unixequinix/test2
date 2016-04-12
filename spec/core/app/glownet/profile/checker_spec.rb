require "rails_helper"

RSpec.describe Profile::Checker, type: :domain_logic do
  subject { Profile::Checker }

  context ".assign_profile" do
    let(:event) { create(:event) }
    let(:tag_uid) { "SOMETAGUID" }
    let(:ticket) { create(:ticket, code: "TICKET_CODE", event: event) }
    let(:profile) { create(:customer_event_profile, event: event) }
    let(:gtag) { create(:gtag, tag_uid: tag_uid, event: event) }
    let(:atts) do
      {
        ticket_code: "TICKET_CODE",
        event_id: event.id,
        customer_tag_uid: gtag.tag_uid
      }
    end

    describe "with customer_event_profile_id" do
      before { create(:credential_assignment, credentiable: gtag, customer_event_profile: profile) }

      it "fails if it does not match any gtag profiles for the event" do
        atts[:customer_event_profile_id] = 9999
        expect { subject.for_transaction(atts) }.to raise_error(RuntimeError, /Fraud/)
      end

      it "returns gtag assigned profile id profile matches that of gtag" do
        atts[:customer_event_profile_id] = profile.id
        gtag.assigned_customer_event_profile = profile
        expect(subject.for_transaction(atts)).to eq(profile.id)
      end
    end

    describe "without customer_event_profile" do
      it "creates a new profile" do
        expect { subject.for_transaction(atts) }.to change(CustomerEventProfile, :count).by(1)
      end

      it "returns that of gtag assigned profile if present" do
        gtag.assigned_customer_event_profile = profile
        expect { @id = subject.for_transaction(atts) }.not_to change(CustomerEventProfile, :count)
        expect(@id).to eq(profile.id)
      end
    end
  end
end
