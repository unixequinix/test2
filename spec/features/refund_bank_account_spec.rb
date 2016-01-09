require "rails_helper"

RSpec.feature "Refund for Bank account", type: :feature do
  context "with account signed in" do
    before :all do
      load_event
      load_customer
      load_gtag
      to_login
    end

    describe "a customer" do
      it "should be able claim and get the credits into his bank account" do
        visit "/#{@event_creator.event.slug}/bank_account_claims/new"
        within("form") do
          fill_in(("euro_bank_account_claim_form_swift"), with: "BSABESBB")
          fill_in(("euro_bank_account_claim_form_iban"), with: "ES6200810575700001135015")
          check "euro_bank_account_claim_form_agreed_on_claim"
        end
        click_button(t("claims.button"))
        expect(current_path).to eq("/#{@event_creator.event.slug}/refunds/success")
      end
    end
  end

  private

  def load_customer
    @customer = build(
      :customer,
      event: @event,
      confirmation_token: nil,
      confirmed_at: Time.now
    )
    create(:customer_event_profile, customer: @customer, event: @event)
  end

  def load_gtag
    @gtag = create(:gtag, event: @event)
    create(:gtag_credit_log, gtag: @gtag, amount: 30)
    @gtag_registration = create(:credential_assignment_g_a,
      credentiable: @gtag,
      customer_event_profile: CustomerEventProfile.first
    )
    @gtag_registration.credentiable.event = @event
    @gtag_registration.save
  end

  def load_event
    @event_creator = EventCreator.new(build(:event,
      gtag_registration: true,
      aasm_state: "claiming_started",
      currency: "GBP",
      host_country: "GB").to_hash_parameters
    )
    @event_creator.save
    @event = @event_creator.event
  end

  def to_login
    login_as(@customer, scope: :customer)
  end
end
