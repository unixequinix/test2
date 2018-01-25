require 'rails_helper'

RSpec.describe "Orders on admin panel", type: :feature do
  let(:event) { create(:event, state: "launched") }
  let(:user) { create(:user, role: "admin") }
  let!(:order1) { create(:order, :with_credit, status: "completed", event: event) }
  let!(:order2) { create(:order, :with_credit, status: "completed", event: event) }
  let!(:order3) { create(:order, :with_credit, status: "completed", event: event) }
  let!(:order4) { create(:order, :with_credit, status: "refunded", event: event) }
  let!(:order5) { create(:order, :with_credit, status: "refunded", event: event) }
  let!(:order6) { create(:order, :with_credit, status: "failed", event: event) }
  let!(:order7) { create(:order, :with_credit, status: "cancelled", event: event) }

  before(:each) do
    login_as(user, scope: :user)
  end

  describe "index: " do
    before { visit admins_event_orders_path(event) }

    it "click on an Order number and redirects to Order view" do
      all('tbody')[0].all('tr')[6].all('a')[0].click
      expect(page).to have_current_path(admins_event_order_path(event, order1))
    end
    it "click on an Order customer and redirects to the Customer view" do
      @customer = event.orders[0].customer
      all('tbody')[0].all('tr')[6].all('a')[1].click
      expect(page).to have_current_path(admins_event_customer_path(event, @customer))
    end
  end

  describe "verify information from orders list: " do
    before { visit admins_event_orders_path(event) }

    it "verify Order number" do
      @number = all('tbody')[0].all('tr')[0].all('td')[0].text
      expect(@number).to eq(event.orders[6].number)
    end
    it "verify Order customer" do
      @customer_email = all('tbody')[0].all('tr')[0].all('td')[1].text
      expect(@customer_email).to eq(event.orders[6].customer.email)
    end
    it "verify Order amount" do
      @amount = all('tbody')[0].all('tr')[0].all('td')[2].text.split(' ')[0].to_f
      expect(@amount).to eq(event.orders[6].total.to_f)
    end
    it "verify Order state" do
      @status = all('tbody')[0].all('tr')[0].all('td')[4].text.downcase
      expect(@status).to eq(event.orders[6].status)
    end
  end

  describe "verify total credit from an Order: " do
    before { visit admins_event_orders_path(event) }

    it "verify total credit from a Completed Order" do
      @total_completed = all('h3')[0].text.split(' ')[0].to_f
      expect(@total_completed).to eq(event.orders[0].total.to_f + event.orders[1].total.to_f + event.orders[2].total.to_f)
    end
    it "verify total credit from a Refounded Order" do
      @total_refunded = all('h3')[1].text.split(' ')[0].to_f
      expect(@total_refunded).to eq(event.orders[3].total.to_f + event.orders[4].total.to_f)
    end
    it "verify total credit from a Failed Order" do
      @total_failed = all('h3')[2].text.split(' ')[0].to_f
      expect(@total_failed).to eq(event.orders[5].total.to_f)
    end
    it "verify total credit from a Cancelled Order" do
      @total_cancelled = all('h3')[3].text.split(' ')[0].to_f
      expect(@total_cancelled).to eq(event.orders[6].total.to_f)
    end
  end

  describe "verify number of orders: " do
    before { visit admins_event_orders_path(event) }

    it "verify number of Completed Orders" do
      expect(Order.completed.count).to eq(3)
    end
    it "verify number of Refounded Orders" do
      expect(Order.refunded.count).to eq(2)
    end
    it "verify number of Failed Orders" do
      expect(Order.failed.count).to eq(1)
    end
    it "verify number of Cancelled Orders" do
      expect(Order.cancelled.count).to eq(1)
    end
  end
end
