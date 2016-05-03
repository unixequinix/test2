require "rails_helper"

RSpec.describe Profile::Checker, type: :domain_logic do
  subject { Profile::Checker }
  let(:event)   { create(:event) }
  let(:tag_uid) { "SOMETAGUID" }
  let(:ticket)  { create(:ticket, code: "CODE", event: event) }
  let(:profile) { create(:profile, event: event) }
  let(:gtag)    { create(:gtag, tag_uid: tag_uid, event: event) }
  let(:atts)    { { ticket_code: "CODE", event_id: event.id, customer_tag_uid: gtag.tag_uid } }

  context ".for_credentiable" do
    let(:customer) { create(:customer, event: event) }

    context "when credentiable does't have a profile assigned" do
      before { gtag.update!(assigned_profile: nil) }

      describe "when customer has a profile" do
        it "assings it" do
          subject.for_credentiable(gtag, customer)
          expect(customer.profile).to eq(customer.profile)
        end
      end

      describe "when customer doesnt have a profile" do
        before { customer.update!(profile: nil) }

        it "creates a profile and assigns it" do
          subject.for_credentiable(gtag, customer)
          customer.reload
          expect(customer.profile).not_to be_nil
        end
      end
    end

    context "when credentiable has a profile assigned" do
      before { gtag.update!(assigned_profile: profile) }

      describe "which already has a customer" do
        it "fails" do
          expect(profile.customer).not_to be_nil
          expect { subject.for_credentiable(gtag, customer) }.to raise_error(RuntimeError, /Fraud/)
        end
      end

      describe "which doesn't have a customer," do
        before { profile.update!(customer: nil) }

        describe "when current customer already has a profile" do
          let(:portal_profile)  { create(:profile, event: event) }
          let(:portal_customer) { portal_profile.customer }

          before(:each) do
            subject.for_credentiable(gtag, portal_customer)
            # work is done in the back, so reload
            [portal_customer, gtag, profile, portal_profile].map(&:reload)
          end

          it "assigns the customer profile to the credentiable" do
            expect(gtag.assigned_profile).to eq(portal_profile)
          end

          it "changes the profile in the associated tables" do
            expect(profile).to be_deleted
          end

          it "changes the credential assignments from credentiable to customer profile" do
            expect(portal_profile.credential_assignments).to eq(gtag.credential_assignments)
          end
        end

        describe "when current customer doesn't have a profile" do
          before { customer.update!(profile: nil) }

          it "assigns credentiable profile to customer" do
            subject.for_credentiable(gtag, customer)
            customer.reload
            expect(gtag.assigned_profile).to eq(profile)
            expect(customer.profile).to eq(profile)
          end
        end
      end
    end
  end

  context ".for_transaction" do
    describe "with profile_id" do
      before { create(:credential_assignment, credentiable: gtag, profile: profile) }

      it "fails if it does not match any gtag profiles for the event" do
        atts[:profile_id] = 9999
        expect { subject.for_transaction(atts) }.to raise_error(RuntimeError, /Fraud/)
      end

      it "returns gtag assigned profile id profile matches that of gtag" do
        atts[:profile_id] = profile.id
        gtag.assigned_profile = profile
        expect(subject.for_transaction(atts)).to eq(profile.id)
      end
    end

    describe "without profile" do
      it "without finding the gtag also creates a profile" do
        atts[:customer_tag_uid] = "NOTTHERE"
        expect { subject.for_transaction(atts) }.to change(Profile, :count).by(1)
      end

      it "sends back the newly created id" do
        expect(subject.for_transaction(atts)).to be_kind_of(Integer)
      end

      it "creates a new profile" do
        expect { subject.for_transaction(atts) }.to change(Profile, :count).by(1)
      end

      it "returns that of gtag assigned profile if present" do
        gtag.assigned_profile = profile
        expect { @id = subject.for_transaction(atts) }.not_to change(Profile, :count)
        expect(@id).to eq(profile.id)
      end

      it "assigns the profile created to the gtag" do
        id = subject.for_transaction(atts)
        expect(gtag.assigned_profile.id).to eq(id)
      end
    end
  end
end
