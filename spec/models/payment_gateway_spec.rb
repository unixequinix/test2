require "spec_helper"

RSpec.describe PaymentGateway, type: :model do
  subject { create(:payment_gateway) }

  it "should have refund action if bank_account" do
    subject.name = "bank_account"
    expect(subject.actions).to include("refund")
  end

  it "should have refund and topup if paypal" do
    subject.name = "paypal"
    expect(subject.actions).to include("refund")
    expect(subject.actions).to include("topup")
  end
end
