require "rails_helper"

RSpec.describe ClaimsPresenter, type: :presenter do
  let(:event) { create(:event, :gtag_assignation, :refunds, :pre_event) }
  let(:gtag) { create(:gtag, :assigned, event: event) }
  let(:profile) { gtag.profile }
  let(:dashboard) { OpenStruct.new(profile: profile, gtag: profile.active_gtag, event: event) }
  subject { ClaimsPresenter.new(dashboard, nil) }

  describe ".can_render?" do
    context "when refunds are active and profile has a gtag" do
      it "returns true" do
        expect(subject.can_render?).to be_truthy
      end
    end

    context "when refunds are disabled" do
      before { event.update(refunds: false) }

      it "returns false" do
        expect(subject.can_render?).to be_falsy
      end
    end

    context "when profile doens't have a gtag" do
      before { profile.active_gtag.update(profile: nil) }

      it "returns false" do
        profile.reload
        expect(subject.can_render?).to be_falsy
      end
    end
  end
end
