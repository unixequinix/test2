require "rails_helper"

RSpec.describe Profile::Checker, type: :domain_logic do
  subject { Profile::Checker }
  let(:event) { create(:event) }
  let(:tag_uid) { "SOMETAGUID" }
  let(:ticket) { create(:ticket, code: "CODE", event: event) }
  let(:profile) { create(:profile, event: event) }
  let(:customer) { create(:profile, :with_customer, event: event).customer }
  let(:gtag_profile) { create(:profile, event: event) }
  let(:transaction) { create(:credential_transaction, event_id: event.id, profile_id: gtag_profile.id) }
  let(:gtag) { create(:gtag, tag_uid: tag_uid, event: event) }
  let(:atts) { { ticket_code: "CODE", event_id: event.id, customer_tag_uid: gtag.tag_uid } }

  describe ".for_transaction" do
    context "with profile_id" do
      before { gtag.update profile: gtag_profile }

      it "reaassings the current profile of the gtag" do
        subject.for_transaction(gtag, profile.id, event.id)
        gtag.reload
        expect(gtag.profile).to eq(profile)
      end

      it "merges the old gtag profile transactions to the transaction profile" do
        expect(transaction.profile_id).to eq(gtag_profile.id)
        subject.for_transaction(gtag, profile.id, event.id)
        transaction.reload
        expect(transaction.profile_id).to eq(profile.id)
      end

      it "raises an error if the profile already has a gtag" do
        new_gtag = create(:gtag, event: event)
        new_gtag.update profile: profile
        expect { subject.for_transaction(gtag, profile.id, event.id) }.to raise_error(RuntimeError, /Profil/)
      end
    end

    context "without profile_id" do
      it "sends back the newly created id" do
        expect(subject.for_transaction(gtag, nil, event.id)).to be_kind_of(Integer)
      end

      it "creates a new profile" do
        expect { subject.for_transaction(gtag, nil, event.id) }.to change(Profile, :count).by(1)
      end

      it "returns that of gtag assigned profile if present" do
        gtag.profile = profile
        expect { @id = subject.for_transaction(gtag, nil, event.id) }.not_to change(Profile, :count)
        expect(@id).to eq(profile.id)
      end

      it "assigns the profile created to the gtag" do
        id = subject.for_transaction(gtag, nil, event.id)
        expect(id).not_to be_nil
        expect(gtag.reload.profile&.id).to eq(id)
      end
    end
  end

  describe ".for_credentiable" do
    context "when gtag doesn't have a profile" do
      it "assigns it to the customer profile" do
        subject.for_credentiable(gtag, customer.profile)
        expect(gtag.profile).to eq(customer.profile)
      end
    end

    context "when both have a profile" do
      before { gtag.update(profile: gtag_profile) }
      it "assigns it to the customer profile" do
        subject.for_credentiable(gtag, customer.profile)
        gtag.reload
        expect(gtag.profile).to eq(customer.profile)
      end
    end

    context "when the object is already assigned" do
      before { gtag.update(profile: create(:profile, :with_customer, event: event)) }
      it "returns nil" do
        expect(subject.for_credentiable(gtag, customer.profile)).to be_nil
      end

      it "doesn't assign it" do
        expect(gtag.profile).not_to eq(customer.profile.id)
      end
    end
  end

  describe ".profile_merger" do
    before { gtag.update profile: gtag_profile }
    it "merges the transactions of two profiles" do
      expect(transaction.profile_id).to eq(gtag_profile.id)
      subject.profile_merger(profile, gtag.profile)
      transaction.reload
      expect(transaction.profile_id).to eq(profile.id)
    end
  end
end
