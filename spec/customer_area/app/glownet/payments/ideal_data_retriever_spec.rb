require "rails_helper"

RSpec.describe Payments::IdealDataRetriever, type: :domain_logic do
  let(:order) do
    create(:order)
  end

  let(:event) do
    order.profile.event
  end

  subject do
    params = {
      financial_institution: "Rabobank"
    }
    Payments::IdealDataRetriever.new(event, order).with_params(params)
  end

  context ".payment_type" do
    it "should return the payment type for Ideal" do
      expect(subject.payment_type).to eq("IDL")
    end
  end

  context ".success_url" do
    it "should return the payment type for Ideal" do
      expect(subject.success_url).to include(
        "payment_services/ideal/asynchronous_payments/success")
    end
  end

  context ".failure_url" do
    it "should return the payment type for Ideal" do
      expect(subject.failure_url).to include("payment_services/ideal/asynchronous_payments/error")
    end
  end

  context ".confirm_url" do
    it "should return the payment type for Ideal" do
      expect(subject.confirm_url).to include("payment_services/ideal/asynchronous_payments")
    end
  end
end
