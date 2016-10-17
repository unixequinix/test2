require "rails_helper"

RSpec.feature "Refund for Bank account", type: :feature do
  let(:event) do
    EventCreator.new(event_to_hash_parameters(build(:event, :refunds, :finished, refund_services: 7))).save
  end
  let(:gtag) { create(:gtag, :assigned_with_customer, event: event) }
  let(:profile) { gtag.assigned_profile }
  let(:customer) { profile.customer }

  context "when logged in" do
    before { login_as(customer, scope: :customer) }

    context "when the customer has credits" do
      before { profile.update(credits: 20, refundable_credits: 20, final_balance: 20, final_refundable_balance: 20) }

      it "has access to the form" do
        visit new_event_bank_account_claim_path(event)

        within("form") do
          fill_in("euro_bank_account_claim_form_swift", with: "BSABESBB")
          fill_in("euro_bank_account_claim_form_iban", with: "ES6200810575700001135015")
          check "euro_bank_account_claim_form_agreed_on_claim"
        end
        click_button(t("claims.button"))

        expect(current_path).to eq(success_event_refunds_path(event))
      end
    end

    context "when customer doesn't have credits" do
      it "is redirected to the dashboard" do
        visit new_event_bank_account_claim_path(event)
        expect(current_path).to eq(customer_root_path(event))
      end
    end
  end
end
