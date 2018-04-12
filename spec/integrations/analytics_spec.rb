require 'rails_helper'

RSpec.describe "Analytics in the admin panel", type: :feature do
  let(:event) { create(:event, state: "launched") }
  let(:user) { create(:user, role: :promoter) }
  let!(:registration) { create(:event_registration, event: event, email: user.email, user: user) }

  before(:each) do
    @online_topups = create_list(:order, 3, event: event, money_base: 10, money_fee: 5)
    @online_topups.map(&:complete!)
    @onsite_topups = create_list(:poke, 3, :as_topups, event: event)
    @sales = create_list(:poke, 3, :as_sales, event: event)
    @purchases = create_list(:poke, 3, :as_purchase, event: event)
    @customers = create_list(:customer, 3, event: event, anonymous: false)
    @customers.each do |customer|
      gtag = create(:gtag, event: event, customer: customer, credits: rand(10..50))
      customer.reload
      create(:refund, event: event, customer: customer, credit_base: gtag.credits, status: 2)
    end

    login_as(user, scope: :user)
  end

  context "visit pages on analytics dashboard" do
    before { visit admins_event_analytics_path(event) }
    # TODO: fmoya keep on working from more difficult cases
    it "shows total topups" do
      expect(find('#topups .analytic-card-title .number').text).to include(number_to_reports(@online_topups.pluck(:money_base, :money_fee).flatten.sum.to_f + @onsite_topups.sum(&:monetary_total_price).to_f))
    end

    it "shows total sales" do
      expect(find('#sales .analytic-card-title .number').text).to include(number_to_reports(@sales.sum(&:credit_amount).abs.to_f))
    end

    it "shows total spending power" do
      expect(find('#spending_power .analytic-card-title .number').text).to include(number_to_reports(event.total_spending_power.abs.to_f))
    end

    it "shows total spending customers" do
      expect(find('#spending_customers .analytic-card-title .number').text.to_f.to_s).to include(number_to_reports(@sales.pluck(:customer_id).uniq.count.to_f))
    end

    it "shows total products" do
      expect(find('#products .analytic-card-title .number').text.to_f.to_s).to include(number_to_reports(@sales.pluck(:product_id).uniq.count.to_f))
    end

    it "shows total activations" do
      expect(find('#activations .analytic-card-title .number').text.to_f.to_s).to include(number_to_reports(event.customers.count.to_f))
    end
  end
end
