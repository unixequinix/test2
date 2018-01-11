require 'rails_helper'

RSpec.describe "Tests on login view in customer portal", type: :feature do

  let(:event) { create(:event, state: "launched") }
  let(:customer) { create(:customer, event: event) }
  before(:each) {visit event_login_path(event)}
  
  describe "login" do
    it "correctly" do
      fill_in 'customer_email', with: customer.email.to_s
      fill_in 'customer_password', with: customer.password.to_s
      find("input[name=commit]").click
      expect(page).to have_current_path(event_path(event))
    end
  end
  describe "don't login because" do
    it "non-existent email" do
      fill_in 'customer_email', with: "non-existent@email.com"
      fill_in 'customer_password', with: customer.password.to_s
      find("input[name=commit]").click
      expect(page).not_to have_current_path(event_path(event))
    end
    
    it "incorrect password" do
      fill_in 'customer_email', with: customer.email.to_s
      fill_in 'customer_password', with: "incorrect"
      find("input[name=commit]").click
      expect(page).not_to have_current_path(event_path(event))
    end
  end
end
