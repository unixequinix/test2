require 'rails_helper'

RSpec.describe "Create an online order", type: :feature do
  let(:event) { SampleEvent.run }
  let(:customer) { create(:customer, email: "test@customer.com", event: event, anonymous: false) }
  let(:ticket) { create(:ticket, event: event, customer: customer) }
  let(:station) { event.stations.find_by(category: "customer_portal") }

  before do
    @item = event.catalog_items.last
    ticket.reload
    create(:payment_gateway, event: event, topup: true, name: "paypal", login: Figaro.env.paypal_login, password: Figaro.env.paypal_password, signature: Figaro.env.paypal_signature) # rubocop:disable Metrics/LineLength
    create(:station_catalog_item, station: station, catalog_item: @item, price: 0.0)

    login_as(customer, scope: :customer)
    visit new_event_order_path(event)
  end

  context "when total is 0" do
    it "skips the payment gateway" do
      within("#checkout-form") do
        find("#amount-input-#{event.credit.id}", visible: false).set 0
        all("#amount-input-#{@item.id} option")[1].select_option
      end
      find("button[name=commit]").click

      order = event.orders.last

      expect(page).to have_current_path(event_order_path(event, order))
      expect { find_link("pay_link").click }.to change { order.reload.completed? }.to(true)

      expect(order.order_items.map(&:catalog_item)).to include @item
      expect(page).to have_current_path(success_event_order_path(event, order))
    end

    it "completes the order" do
      order = create(:order, event: event, customer: customer, completed_at: Time.current)

      visit event_order_path(event, order)
      expect { find_link("pay_link").click }.to change { order.reload.completed? }.to(true)
      expect(page).to have_current_path(success_event_order_path(event, order))
    end
  end

  context "when total is positive" do
    it "redirects to the payment gateway" do
      within("#checkout-form") do
        find("#amount-input-#{event.credit.id}", visible: false).set 50
        all("#amount-input-#{@item.id} option")[1].select_option
      end

      find("button[name=commit]").click
      @order = event.orders.last
      expect(page).to have_current_path(event_order_path(event, @order))

      begin
        find_link("pay_link").click
      rescue ActionController::RoutingError
        expect(current_url).to include("paypal")
      end

      expect(@order.order_items.map(&:catalog_item)).to include @item
    end

    it "adds the credits to the customers balance" do
      within("#checkout-form") { find("#amount-input-#{event.credit.id}", visible: false).set 50 }

      find("button[name=commit]").click
      @order = event.orders.last
      expect(page).to have_current_path(event_order_path(event, @order))

      begin
        find_link("pay_link").click
      rescue ActionController::RoutingError
        expect(current_url).to include("paypal")
      end

      expect { @order.complete! }.to change { customer.global_credits }.by(50)
      expect(@order.order_items.map(&:catalog_item)).to include event.credit
    end
  end
end
