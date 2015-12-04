# coding UTF-8
=begin
require "rails_helper"

RSpec.feature "Stripe Payment", type: :feature do

  context "with account signed in" do
    before :all do
      load_event
      load_customer
      to_login
      I18n.locale = :es
    end

    describe "an admin", js: true  do
      it "should be able to set stripe as payment service" do
        visit "/admins/events/#{@event.slug}/payment_settings"
        click_link("Activar Cuenta")
        fill_in("stripe_payment_settings_form_email", with: "test@admin.es")
        fill_in("stripe_payment_settings_form_currency", with: "GBP")
        select("Reino Unido", from: "stripe_payment_settings_form_country")
        fill_in("stripe_payment_settings_form_bank_account", with: "000123456789")
        click_button("Actualizar")
        sleep(5)
        expect(current_path).to eq("/admins/events/#{@event.slug}/payment_settings")
      end
    end
  end

  private

  def load_customer
    @customer = build(:customer,
      event: @event,
      confirmation_token: nil,
      confirmed_at: Time.now)
    create(:customer_event_profile, customer: @customer, event: @event)
  end

  def load_event
    @event_creator = EventCreator.new(build(
      :event,
      gtag_registration: true,
      features: 3,
      aasm_state: "launched",
      payment_service: "stripe").to_hash_parameters)
    @event_creator.save
    @event = @event_creator.event
  end

  def to_login
    admin = create(:admin)
    login_as(admin, scope: :admin)
  end
end
=end