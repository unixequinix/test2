# coding UTF-8
=begin
require "rails_helper"

RSpec.feature "Stripe Payment", type: :feature do

  context "with account signed in" do
    before :all do
      load_event
      load_customer
      load_gtag
      to_login
      I18n.locale = :es
    end

    describe "a customer", js: true  do
      it "should be able to buy new credits using stripe platform" do
        binding.pry
        visit "/#{@event_creator.event.slug}/checkouts/new"
        click_button(t("checkout.button"))
        click_button(t("orders.button"))
        fill_in("card_number", with: "4242424242424242")
        fill_in("card_verification", with: "123")
        select "2020", :from => "exp_year"
        click_button(t("orders.stripe.button"))
        binding.pry
        sleep 3
        expect(current_path).to eq("/#{@event_creator.event.slug}/payments/success")
      end
    end
  end

  private

  def load_customer
    @customer = build(:customer, event: @event, confirmation_token: nil, confirmed_at: Time.now)
    create(:customer_event_profile, customer: @customer, event: @event)
  end

  def load_gtag
    @gtag = create(:gtag, event: @event)
    create(:gtag_credit_log, gtag: @gtag, amount: 30)
    @gtag_registration = create(:gtag_registration, gtag: @gtag, aasm_state: "assigned", customer_event_profile: CustomerEventProfile.first)
    @gtag_registration.event = @event
    @gtag_registration.save
  end

  def load_event
    @event_creator = EventCreator.new(build(:event,gtag_registration: true, features: 3, aasm_state: "launched", currency: "USD", host_country: "US", payment_service: "stripe").to_hash_parameters)
    @event_creator.save
    @event = @event_creator.event
  end

  def to_login
    login_as(@customer, scope: :customer)
  end
end
=end
