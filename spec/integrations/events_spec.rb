require 'rails_helper'
RSpec.describe "Events in the admin panel", type: :feature do
  let(:user) { create(:user, role: :admin) }
  let(:event) { create(:event, state: "created") }

  before { login_as(user, scope: :user) }

  describe "show event" do
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
    end

    context "check cards on event dashboard" do
      before { visit admins_event_path(event) }

      it "should have correct outstading value" do
        expect(find('#outstading .analytic-card-title .number').text).to include(number_to_reports(event.cash_income - event.cash_outcome))
      end

      it "should have correct spending power value" do
        expect(find('#spending_power .analytic-card-title .number').text).to include(number_to_reports(event.total_spending_power.abs.to_f))
      end
    end
  end

  describe "create event" do
    before { visit new_admins_event_path }

    context "a standard event" do
      it "can be done only filling in name" do
        within("#new_event") { fill_in 'event_name', with: "jakefest #{SecureRandom.hex(6).upcase}" }
        expect { find("input[name=commit]").click }.to change(Event, :count).by(1)
      end

      it "allows to select a timezone" do
        name = "jakefest #{SecureRandom.hex(6).upcase}"
        within("#new_event") { fill_in('event_name', with: name) }
        find("#event_timezone").select("(GMT+00:00) UTC")
        expect { find("input[name=commit]").click }.to change(Event, :count).by(1)
        expect(Event.find_by(name: name).timezone).to eql("UTC")
      end
    end

    context "a sample event" do
      before do
        visit sample_event_admins_events_path
        @event = Event.last
      end

      it "creates and event and then redirects you to it" do
        expect(page).to have_current_path(admins_event_path(@event))
      end
    end

    context "by promoter" do
      before { user.promoter! }

      it "can create a standard event" do
        visit new_admins_event_path
        expect(page).to have_current_path(new_admins_event_path)
      end

      it "can create a sample event" do
        visit sample_event_admins_events_path
        expect(page).to have_current_path(admins_events_path)
      end
    end
  end
end
