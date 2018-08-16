require 'rails_helper'

RSpec.describe "Refunds in the admin panel", type: :feature do
  let(:event) { create(:event, state: "launched") }
  let(:user) { create(:user, role: :promoter) }
  let!(:registration) { create(:event_registration, event: event, user: user) }

  before(:each) do
    @customers = create_list(:customer, 3, event: event, anonymous: false)
    @customers.each do |customer|
      gtag = create(:gtag, event: event, customer: customer, final_balance: rand(10..50))
      customer.reload
      create(:refund, event: event, customer: customer, credit_base: gtag.final_balance - 2, credit_fee: 2, status: 2)
      create(:refund, event: event, customer: customer, credit_base: gtag.final_balance - 2, credit_fee: 2, status: 1)
    end

    login_as(user, scope: :user)
  end

  context "visit pages on refunds view" do
    before { visit admins_event_refunds_path(event) }
    it "shows credit base for refunds completed" do
      expect(find('#refund_credits_completed').text).to include(event.refunds.where(status: "completed").sum(&:credit_base).to_f.round(0).to_s)
    end

    it "shows credit fee for refunds completed" do
      expect(find('#refund_fee_completed').text).to include(event.refunds.where(status: "completed").sum(&:credit_fee).to_f.round(0).to_s)
    end

    it "shows credit base for refunds started" do
      expect(find('#refund_credits_completed').text).to include(event.refunds.where(status: "started").sum(&:credit_base).to_f.round(0).to_s)
    end

    it "shows credit fee for refunds started" do
      expect(find('#refund_fee_completed').text).to include(event.refunds.where(status: "started").sum(&:credit_fee).to_f.round(0).to_s)
    end
  end
end
