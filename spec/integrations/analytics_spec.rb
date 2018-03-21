require 'rails_helper'

RSpec.shared_examples "kpis analytics" do
  it "shows the money reconciliation" do
    expect(find("#money_reconciliation_kpi").text).to include(@purchases.sum(&:monetary_total_price).to_f.to_s)
  end

  it "shows the total sales" do
    expect(find("#total_sales_kpi").text).to include(@sales.sum(&:credit_amount).to_f.abs.to_s)
  end

  it "shows the activations" do
    expect(find("#activations_kpi").text).to include(@customers.count.to_i.to_s)
  end
end

RSpec.describe "Analytics in the admin panel", type: :feature do
  let(:event) { create(:event, state: "launched") }
  let(:user) { create(:user, role: :promoter) }
  let!(:registration) { create(:event_registration, event: event, email: user.email, user: user) }

  before(:each) do
    @topups = create_list(:poke, 10, :as_topups, event: event)
    @sales = create_list(:poke, 10, :as_sales, event: event)
    @purchases = create_list(:poke, 10, :as_purchase, event: event)
    @customers = create_list(:customer, 10, event: event)
    login_as(user, scope: :user)
  end

  context "visit pages on analytics dashboard" do
    before { visit admins_event_analytics_path(event) }

    include_examples "kpis analytics"
  end

  context "visit pages on event dashboard" do
    before { visit admins_event_path(event) }

    include_examples "kpis analytics"
  end
end
