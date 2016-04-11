require "rails_helper"

RSpec.describe Profile::Checker, type: :domain_logic do
  subject { Profile::Checker }

  context ".assign_profile" do
    let(:event)   { create(:event) }
    let(:tag_uid) { "SOMETAGUID" }
    let(:ticket)  { create(:ticket, code: "TICKET_CODE", event: event) }
    let(:profile) { create(:customer_event_profile, event: event) }
    let(:gtag)    { create(:gtag, tag_uid: tag_uid, event: event) }
    let(:atts) do
      {
        ticket_code: "TICKET_CODE",
        event_id: event.id,
        customer_tag_uid: subject.customer_tag_uid
      }
    end

    describe "with customer_event_profile_id" do
      before do
        CredentialAssignment.create(credentiable: gtag, customer_event_profile: profile)
        atts[:customer_event_profile_id] = 9999
      end

      it "fails if it does not match any gtag profiles for the event" do
        expect { subject.assign_profile(subject, atts) }.to raise_error(RuntimeError, /Mismatch/)
      end

      it "does not change a thing if profile matches that of gtag" do
        subject.customer_event_profile = profile
        atts[:customer_event_profile_id] = profile.id
        gtag.assigned_customer_event_profile = profile
        expect do
          subject.assign_profile(subject, atts)
        end.not_to change(subject, :customer_event_profile)
      end
    end

    describe "without customer_event_profile" do
      it "creates a profile for the transaction passed" do
        expect do
          subject.assign_profile(subject, atts)
        end.to change(subject, :customer_event_profile)
      end

      it "assigns that of gtag if present" do
        gtag.assigned_customer_event_profile = profile
        expect { subject.assign_profile(subject, atts) }.to change(subject, :customer_event_profile)
        expect(subject.customer_event_profile).to eq(profile)
      end
    end
  end
end
