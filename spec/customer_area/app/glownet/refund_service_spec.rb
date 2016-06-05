require "rails_helper"

RSpec.describe RefundService, type: :domain_logic do
  let(:claim) { create(:claim) }
  subject { RefundService.new(claim) }

  describe ".create" do
    let(:params) { { claim_id: claim.id, amount: 19.99, status: "PENDING", payment_solution: "a" } }
    let(:mailer_double) { double("ClaimMailer", deliver: true) }

    before do
      allow(claim).to receive(:complete!)
      allow(claim.profile.event).to receive(:standard_credit_price).and_return(1)
      allow(mailer_double).to receive(:deliver_later).and_return true
      allow(ClaimMailer).to receive(:completed_email).and_return mailer_double
      Station.create!(event: claim.profile.event, name: "Customer Portal",
                      category: "customer_portal")

      YAML.load_file(Rails.root.join("db", "seeds", "standard_credits.yml")).each do |data|
        Credit.create!(standard: data["standard"],
                       currency: data["currency"],
                       value: data["value"],
                       catalog_item_attributes: { event_id: claim.profile.event.id,
                                                  name: data["name"],
                                                  step: data["step"],
                                                  min_purchasable: data["min_purchasable"],
                                                  max_purchasable: data["max_purchasable"],
                                                  initial_amount: data["initial_amount"] })
      end
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
  end
end
