require 'rails_helper'

RSpec.describe "Orders on admin panel", type: :feature do
  let(:event) { create(:event, state: "launched") }
  let(:user) { create(:user, role: "admin") }

  before(:each) do
    login_as(user, scope: :user)
  end

  describe "index: " do
    let!(:order) { create(:order, :with_credit, event: event) }

    before { visit admins_event_orders_path(event) }

    it "click on an Order number and redirects to Order view" do
      expect(page.all(:link, nil, href: admins_event_order_path(event, order)).any?).to be_truthy
    end
    it "click on an Order customer and redirects to the Customer view" do
      expect(page.all(:link, nil, href: admins_event_customer_path(event, order.customer)).any?).to be_truthy
    end

    it "must include number" do
      expect(page.all('td', text: order.number).any?).to be_truthy
    end
    it "must include customer" do
      expect(page.all('td', text: order.customer.email).any?).to be_truthy
    end
    it "must include amount" do
      expect(page.all('td', text: order.money_total).any?).to be_truthy
    end
    it "must include state" do
      expect(page.all('td', text: order.status.humanize).any?).to be_truthy
    end
  end
end
