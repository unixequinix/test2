require "rails_helper"

RSpec.describe RefundService, type: :domain_logic do
  let(:claim) { create(:claim) }
  subject { RefundService.new(claim) }

  describe ".create" do
    let(:params) { { claim_id: claim.id, amount: 19.99, status: "PENDING" } }
    let(:mailer_double) { double("ClaimMailer", deliver: true) }

    before do
      allow(claim).to receive(:complete!)
      allow(mailer_double).to receive(:deliver_later).and_return true
      allow(ClaimMailer).to receive(:completed_email).and_return mailer_double
    end

    it "creates a refund" do
      expect { subject.create(params) }.to change { Refund.count }.by(1)
    end

    it "filters out unwanted parameters" do
      invalid_params = params.merge(invalid_param: "INVALID")
      expect { subject.create(invalid_params) }.to change { Refund.count }.by(1)
    end

    it "should return false if status is not PENDING or SUCCESS" do
      params[:status] = "INVALID"
      expect(subject.create(params)).to be_falsey
    end

    it "marks claim as completed" do
      expect(claim).to receive(:complete!)
      subject.create(params)
    end

    it "notifies the client" do
      expect(ClaimMailer).to receive(:completed_email).and_return mailer_double
      subject.create(params)
    end

    it "updates the profiles balance to reflect the refund" do
      expect(claim.customer_event_profile).to receive(:refund!)
      subject.create(params)
    end
  end
end
