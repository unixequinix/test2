require 'rails_helper'

RSpec.describe "Tests on register view in customer portal", type: :feature do
  let(:event) { create(:event, state: "launched") }
  before(:each) { visit event_register_path(event) }

  describe "create an account" do
    it "correctly" do
      within("#new_customer") do
        fill_in 'customer_email', with: "customer@email.com"
        fill_in 'customer_password', with: "passw0rd"
        fill_in 'customer_password_confirmation', with: "passw0rd"
        fill_in 'customer_first_name', with: "First"
        fill_in 'customer_last_name', with: "Last"
        find('.mdl-switch').click
      end
      expect { find("input[name=commit]").click }.to change(ActionMailer::Base.deliveries, :count).by(1)
      expect(unread_emails_for("customer@email.com")).to be_present
      open_email("customer@email.com")
      click_first_link_in_email
      expect(page).to have_current_path(event_path(event))
    end
  end
  describe "don't create an account because" do
    it "existent email" do
      customer = create(:customer, event: event)
      within("#new_customer") do
        fill_in 'customer_email', with: customer.email
        fill_in 'customer_password', with: "passw0rd"
        fill_in 'customer_password_confirmation', with: "passw0rd"
        fill_in 'customer_first_name', with: "First"
        fill_in 'customer_last_name', with: "Last"
        find('.mdl-switch').click
      end
      expect { find("input[name=commit]").click }.not_to change(ActionMailer::Base.deliveries, :count)
    end

    it "incorrect password" do
      within("#new_customer") do
        fill_in 'customer_email', with: "customer@email.com"
        fill_in 'customer_password', with: "pass"
        fill_in 'customer_password_confirmation', with: "pass"
        fill_in 'customer_first_name', with: "First"
        fill_in 'customer_last_name', with: "Last"
        find('.mdl-switch').click
      end
      expect { find("input[name=commit]").click }.not_to change(ActionMailer::Base.deliveries, :count)
    end

    it "incorrect password confirmation" do
      within("#new_customer") do
        fill_in 'customer_email', with: "customer@email.com"
        fill_in 'customer_password', with: "passw0rd"
        fill_in 'customer_password_confirmation', with: "otherpassw0rd"
        fill_in 'customer_first_name', with: "First"
        fill_in 'customer_last_name', with: "Last"
        find('.mdl-switch').click
      end
      expect { find("input[name=commit]").click }.not_to change(ActionMailer::Base.deliveries, :count)
    end

    it "empty fields" do
      within("#new_customer") do
        fill_in 'customer_email', with: "customer@email.com"
        fill_in 'customer_password', with: "passw0rd"
        fill_in 'customer_password_confirmation', with: "passw0rd"
        fill_in 'customer_first_name', with: ""
        fill_in 'customer_last_name', with: ""
        find('.mdl-switch').click
      end
      expect { find("input[name=commit]").click }.not_to change(ActionMailer::Base.deliveries, :count)
    end

    it "not accepted terms of use" do
      within("#new_customer") do
        fill_in 'customer_email', with: "customer@email.com"
        fill_in 'customer_password', with: "passw0rd"
        fill_in 'customer_password_confirmation', with: "passw0rd"
        fill_in 'customer_first_name', with: "First"
        fill_in 'customer_last_name', with: "Last"
      end
      expect { find("input[name=commit]").click }.not_to change(ActionMailer::Base.deliveries, :count)
    end
  end
end
