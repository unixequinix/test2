require "rails_helper"

RSpec.describe Profile::Checker, type: :domain_logic do
  subject { Profile::Checker }
  let(:event) { create(:event) }
  let(:tag_uid) { "SOMETAGUID" }
  let(:ticket) { create(:ticket, code: "CODE", event: event) }
  let(:profile) { create(:profile, event: event) }
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
end
