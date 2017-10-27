require 'rails_helper'

RSpec.describe "Create an online order", type: :feature do
  let(:event) { SampleEvent.run }
  let(:customer) { create(:customer, email: "test@customer.com", event: event, anonymous: false) }
  let(:ticket) { create(:ticket, event: event, customer: customer) }
  let(:station) { event.stations.find_by(category: "customer_portal") }

  before do
    @catalog_vip_item = event.catalog_items.last
    ticket.reload
    create(:payment_gateway, event: event, topup: true, name: "paypal", login: Figaro.env.paypal_login, password: Figaro.env.paypal_password, signature: Figaro.env.paypal_signature) # rubocop:disable Metrics/LineLength
    create(:station_catalog_item, station: station, catalog_item: @catalog_vip_item, price: 0.0)

    login_as(customer, scope: :customer)
    visit customer_root_path(event)
    expect(page).to have_current_path(customer_root_path(event))
    find_link("new_top_up").click
  end

  context "when total is 0" do
    it "skips the payment gateway" do
      within("#checkout-form") do
        find("#amount-input-#{event.credit.id}", visible: false).set 0
        all("#amount-input-#{@catalog_vip_item.id} option")[1].select_option
      end
      find("button[name=commit]").click
      @order = event.orders.last
      expect(page).to have_current_path(event_order_path(event, @order))

      find_link("pay_link").click

      expect(@order.reload).to be_completed
      expect(@order.order_items.map(&:catalog_item)).to include @catalog_vip_item
      expect(page).to have_current_path(success_event_order_path(event, @order))
    end
  end

  context "when total is positive" do
    it "is buying items with total greater than 0" do
      within("#checkout-form") do
        find("#amount-input-#{event.credit.id}", visible: false).set 50
        all("#amount-input-#{@catalog_vip_item.id} option")[1].select_option
      end

      find("button[name=commit]").click
      @order = event.orders.last
      expect(page).to have_current_path(event_order_path(event, @order))

      begin
        find_link("pay_link").click
      rescue ActionController::RoutingError
        expect(current_url).to include("paypal")
      end
      @order.complete!
      expect(@order.order_items.map(&:catalog_item)).to include @catalog_vip_item
    end

    it "is topup with only credits" do
      within("#checkout-form") { find("#amount-input-#{event.credit.id}", visible: false).set 50 }

      expect do
        find("button[name=commit]").click
        @order = event.orders.last
        expect(page).to have_current_path(event_order_path(event, @order))

        begin
          find_link("pay_link").click
        rescue ActionController::RoutingError
          expect(current_url).to include("paypal")
        end
        @order.complete!
        expect(@order.order_items.map(&:catalog_item)).to include event.credit
      end.to change(customer, :global_credits).by(50)
    end
  end

  it "is located in orders/new and topup with credits" do
    find_link("new_top_up").click
    expect(page).to have_current_path(new_event_order_path(event))
    expect do
      within("#checkout-form") do
        fill_in 'input-range', with: 50
      end

      find("button[name=commit]").click
      @order = event.orders.last
      expect(page).to have_current_path(event_order_path(event, @order))
      @order.complete!
      expect(@order.order_items.map(&:catalog_item)).to include @item_crd
    end.to change(customer, :global_credits)
  end

  it "is located in orders/new and buy items with total of 0" do
    find_link("new_top_up").click
    expect(page).to have_current_path(new_event_order_path(event))

    within("#checkout-form") do
      fill_in 'input-range', with: 0
      all("#amount-input-#{@catalog_item.id} option")[1].select_option
    end

    find("button[name=commit]").click
    @order = event.orders.last
    expect(page).to have_current_path(event_order_path(event, @order))
    @order.complete!
    expect(@order.order_items.map(&:catalog_item)).to include @catalog_item
  end

  it "is located in orders/new and buy items with total greater than 0" do
    find_link("new_top_up").click
    expect(page).to have_current_path(new_event_order_path(event))

    within("#checkout-form") do
      fill_in 'input-range', with: 50
      all("#amount-input-#{@catalog_item.id} option")[1].select_option
    end

    find("button[name=commit]").click
    @order = event.orders.last
    expect(page).to have_current_path(event_order_path(event, @order))
    @order.complete!
    expect(@order.order_items.map(&:catalog_item)).to include @catalog_item
  end
end
