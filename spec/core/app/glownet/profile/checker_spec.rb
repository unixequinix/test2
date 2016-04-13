require "rails_helper"

RSpec.describe Profile::Checker, type: :domain_logic do
  subject { Profile::Checker }
  let(:event)   { create(:event) }
  let(:tag_uid) { "SOMETAGUID" }
  let(:ticket)  { create(:ticket, code: "TICKET_CODE", event: event) }
  let(:profile) { create(:customer_event_profile, event: event) }
  let(:gtag)    { create(:gtag, tag_uid: tag_uid, event: event) }
  let(:atts) do
    {
      ticket_code: "TICKET_CODE",
      event_id: event.id,
      customer_tag_uid: gtag.tag_uid
    }
  end

  context ".for_credentiable" do
    let(:customer) { create(:customer, event: event) }

    describe "without customer event profile assigned" do
      before do
        gtag.update!(assigned_customer_event_profile: nil)
        customer.update!(customer_event_profile: nil)
      end

      it "creates a profile and assigns it" do
        expect(customer.customer_event_profile).to be_nil
        subject.for_credentiable(gtag, customer)
        expect(customer.customer_event_profile).not_to be_nil
      end
    end

    context "with customer event profile assigned" do
      describe "which already has a customer" do
        before do
          gtag.update!(assigned_customer_event_profile: profile)
          expect(profile.customer).not_to be_nil
        end

        it "fails" do
          expect { subject.for_credentiable(gtag, customer) }.to raise_error(RuntimeError, /Fraud/)
        end
      end

      describe "which doesnt have a customer" do
        before do
          gtag.update!(assigned_customer_event_profile: profile)
          profile.update!(customer: nil)
        end

        it "assigns credentiable profile to customer" do
          subject.for_credentiable(gtag, customer)
          customer.reload
          expect(gtag.assigned_customer_event_profile).to eq(profile)
          expect(customer.customer_event_profile).to eq(profile)
        end
      end
    end
  end

  context ".for_transaction" do
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
      it "without finding the gtag also creates a profile" do
        atts[:customer_tag_uid] = "NOTTHERE"
        expect { subject.for_transaction(atts) }.to change(CustomerEventProfile, :count).by(1)
      end

      it "sends back the newly created id" do
        expect(subject.for_transaction(atts)).to be_kind_of(Integer)
      end

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
