require 'rails_helper'

RSpec.describe "Analytics in the admin panel", type: :feature do
  let(:event) { create(:event, state: "launched") }
  let(:user) { create(:user, role: :promoter) }
  let!(:registration) { create(:event_registration, event: event, user: user) }
  let(:station) { create(:station, event: event, category: 'vendor') }

  before(:each) do
    @online_topups = create_list(:order, 3, event: event, money_base: 10, money_fee: 5)
    @online_topups.map(&:complete!)
    @onsite_topups = create_list(:poke, 3, :as_topups, event: event, action: 'record_credit', description: 'topup', station: station)
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
end
