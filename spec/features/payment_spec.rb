=begin
require "rails_helper"

RSpec.feature "Payment", type: :feature do

  context "with account signed in" do
    before :all do
      load_event
      load_customer
      load_gtag
      to_login
      I18n.locale = :en
    end

    describe "a customer", js: true do
      it "should be able to buy new credits" do
        visit "/#{@event_creator.event.slug}/checkouts/new"
        click_button("Confirmar Orden")
        click_button("Pagar")
        fill_in("inputCard", with: "4548812049400004")
        fill_in("cad1", with: "12")
        fill_in("cad2", with: "20")
        fill_in("codseg", with: "123")
        click_button("Pagar")
        fill_in("pin", with: "123456")
        find("img[alt='Aceptar']").click
        click_button("Continuar")
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
    @event_creator = EventCreator.new(build(:event,
      gtag_registration: true,
      features: 3,
      aasm_state: "launched",
      currency: "GBP",
      host_country: "GB").to_hash_parameters)
    @event_creator.save
    @event = @event_creator.event
  end

  def to_login
    login_as(@customer, scope: :customer)
  end
end
=end

