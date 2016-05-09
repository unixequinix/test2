require "rails_helper"

RSpec.describe Payments::SofortDataRetriever, type: :domain_logic do
  let(:order) do
    create(:order)
  end

  let(:event) do
    order.profile.event
  end

  subject do
    params = {}
    params[:consumer_ip_address] = "192.168.1.1"
    params[:consumer_user_agent] = "chrome"

    Payments::SofortDataRetriever.new(event, order).with_params(params)
  end

  context ".payment_type" do
    it "should return the payment type for Sofort" do
      expect(subject.payment_type).to eq("SOFORTUEBERWEISUNG")
    end
  end

  context ".success_url" do
    it "should return the payment type for Sofort" do
      expect(subject.success_url).include?("payment_services/sofort/asynchronous_payments/success")
    end
  end

  context ".failure_url" do
    it "should return the payment type for Sofort" do
      expect(subject.failure_url).include?("payment_services/sofort/asynchronous_payments/error")
    end
  end

  context ".confirm_url" do
    it "should return the payment type for Sofort" do
      expect(subject.confirm_url).include?("payment_services/sofort/asynchronous_payments")
    end
  end
end
