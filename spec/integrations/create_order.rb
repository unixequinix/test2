require 'rails_helper'

RSpec.describe "Create orders on a Customer view", js: true, type: :feature do
  let(:event) { create(:event, state: "launched") }
  let(:user) { create(:user, role: :admin) }
  let(:customer) { create(:customer, event: event, anonymous: false) }
  let!(:access) { create(:access, event: event) }

  before(:each) do
    login_as(user, scope: :user)
    visit admins_event_customer_path(event, customer)
  end

  describe "Create new order: " do
    before(:each) { click_link("new_order_link") }

    it "can be achieved by adding one of each item" do
      within("#new_order") do
        click_link("add_fields")
        find('input.order_item').set(50)
        click_link("add_fields")
        find_all('fieldset')[1].find_all('.grouped_select option', minimum: 1)[1].select_option
        find_all('input.order_item')[1].set(20)
        click_link("add_fields")
        find_all('fieldset')[2].find_all('.grouped_select option', minimum: 1)[2].select_option
        find_all('input.order_item')[2].set(1)
      end
      expect { find("input[name=commit]").click }.to change(Order, :count).by(1)
    end

    it "can be achieved by only adding Alcohol forbidden flag" do
      find('label[for=alcohol_forbidden]').click
      find("input[name=commit]").click
      expect(event.orders.last.catalog_items.last.name).to eq("alcohol_forbidden")
    end

    it "can be achieved by only adding Top Up paid flag" do
      find('label[for=initial_topup]').click
      find("input[name=commit]").click
      expect(event.orders.last.catalog_items.last.name).to eq("initial_topup")
    end

    it "cannot be achieved by adding no items" do
      expect { find("input[name=commit]").click }.not_to change(Order, :count)
    end

    it "can include standard credits" do
      within("#new_order") do
        click_link("add_fields")
        find('input.order_item').set(10)
      end
      find("input[name=commit]").click
      expect(event.orders.last.credits.to_f).to equal(10.0)
    end

    it "can include virtual credits" do
      within("#new_order") do
        click_link("add_fields")
        find_all('.grouped_select option', minimum: 1)[1].select_option
        find('input.order_item').set(10)
      end
      find("input[name=commit]").click
      expect(event.orders.last.virtual_credits.to_f).to equal(10.0)
    end

    it "can include standard and virtual credits" do
      within("#new_order") do
        click_link("add_fields")
        find('input.order_item').set(10)
      end
      within("#new_order") do
        click_link("add_fields")
        find_all('fieldset')[1].find_all('.grouped_select option', minimum: 1)[1].select_option
        find_all('input.order_item')[1].set(20)
      end
      find("input[name=commit]").click
      expect(event.orders.last.credits.to_f).to equal(10.0)
      expect(event.orders.last.virtual_credits.to_f).to equal(20.0)
    end

    it "can be achieved when an order has a negative amount" do
      within("#new_order") do
        click_link("add_fields")
        find('input.order_item').set(-1)
      end
      expect { find("input[name=commit]").click }.to change(Order, :count).by(1)
    end

    it "can be achieved by adding the same item twice" do
      within("#new_order") do
        click_link("add_fields")
        find('input.order_item').set(1)
        click_link("add_fields")
        find_all('input.order_item').last.set(2)
      end
      expect { find("input[name=commit]").click }.to change(Order, :count).by(1)
    end

    it "cannot be achieved when typing a negative number on customer input amount" do
      within("#new_order") do
        fill_in 'order_amount', with: "-5"
      end
      click_link("add_fields")
      find('input.order_item').set("1")
      expect { find("input[name=commit]").click }.not_to change(Order, :count)
    end

    it "cannot be achieved when typing a not valid number on customer input amount" do
      within("#new_order") do
        click_link("add_fields")
        find('input.order_item').set("test")
      end
      expect { find("input[name=commit]").click }.not_to change(Order, :count)
    end

    it "can be achieved with Alcohol Forbidden and Initial Topup flag enabled" do
      find('label[for=alcohol_forbidden]').click
      find('label[for=initial_topup]').click
      find("input[name=commit]").click
      expect(event.orders.last.catalog_items.first.name).to eq("alcohol_forbidden")
      expect(event.orders.last.catalog_items.last.name).to eq("initial_topup")
    end
  end
end
