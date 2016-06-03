require "rails_helper"

RSpec.feature "Refund for Bank account", type: :feature do
  context "with account signed in" do
    before :all do
      load_event
      load_customer
      load_gtag
      login_as(@customer, scope: :customer)
    end

    describe "a customer" do
      it "should be able to claim and get the credits into his bank account" do
        visit "/#{@event_creator.event.slug}/bank_account_claims/new"
        within("form") do
          fill_in("euro_bank_account_claim_form_swift", with: "BSABESBB")
          fill_in("euro_bank_account_claim_form_iban", with: "ES6200810575700001135015")
          check "euro_bank_account_claim_form_agreed_on_claim"
        end

        click_button(t("claims.button"))
        expect(current_path).to eq("/#{@event_creator.event.slug}/refunds/success")
      end
    end
  end

  private

  def load_customer
    @customer = build(:customer, event: @event)
    create(:profile, customer: @customer, event: @event)
  end

  def load_gtag
    @gtag = create(:gtag, event: @event)
    create(:customer_credit_online, profile: Profile.first)
    @gtag_assignment = create(:credential_assignment_g_a,
                              credentiable: @gtag,
                              profile: Profile.first)
    @gtag_assignment.save
  end

  def load_event
    event = build(:event,
                  aasm_state: "finished",
                  currency: "GBP",
                  host_country: "GB",
                  refund_services: 7)
    @event_creator = EventCreator.new(event_to_hash_parameters(event))
    @event_creator.save
    @event = @event_creator.event
  end
end
