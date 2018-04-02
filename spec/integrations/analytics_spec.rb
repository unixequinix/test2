require 'rails_helper'

RSpec.describe "Analytics in the admin panel", type: :feature do
  let(:event) { create(:event, state: "launched") }
  let(:user) { create(:user, role: :promoter) }
  let!(:registration) { create(:event_registration, event: event, email: user.email, user: user) }

  before(:each) do
    @online_topups = create_list(:order, 10, event: event, money_base: 10, money_fee: 5)
    @online_topups.map(&:complete!)
    @onsite_topups = create_list(:poke, 10, :as_topups, event: event)
    @sales = create_list(:poke, 10, :as_sales, event: event)
    @purchases = create_list(:poke, 10, :as_purchase, event: event)
    @customers = create_list(:customer, 10, event: event)
    login_as(user, scope: :user)
  end

  context "visit pages on analytics dashboard" do
    before { visit admins_event_analytics_path(event) }
    # TODO: fmoya keep on working from more difficult cases
    it "shows total topups" do
      expect(find('#topups .analytic-card-title .number').text).to include(number_to_reports(@online_topups.pluck(:money_base, :money_fee).flatten.sum + @onsite_topups.sum(&:monetary_total_price)))
    end

    it "shows total sales" do
      expect(find('#sales .analytic-card-title .number').text).to include(@sales.sum(&:credit_amount).to_f.abs.to_s)
    end

    it "shows total spending power" do
      expect(find('#spending_power .analytic-card-title .number').text).to include(number_to_reports((event.total_spending_power * event.credit.value)))
    end

    it "shows total spending customers" do
      expect(find('#spending_customers .analytic-card-title .number').text).to include(@sales.pluck(:customer_id).uniq.count.to_s)
    end

    it "shows total products" do
      expect(find('#products .analytic-card-title .number').text).to include(@sales.pluck(:product_id).uniq.count.to_s)
    end

    it "shows total activations" do
      expect(find('#activations .analytic-card-title .number').text).to include(event.customers.count.to_s)
    end
  end
end
