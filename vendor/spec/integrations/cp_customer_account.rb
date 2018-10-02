require 'rails_helper'

RSpec.describe "Customer account in customer portal", type: :feature do
  let(:event) { create(:event, state: "launched") }
  let(:customer) { create(:customer, event: event) }
  before(:each) do
    login_as(customer, scope: :customer)
    visit customer_root_path(event)
  end

  describe "edit account" do
    before(:each) { click_link("edit_account") }
    it "first name" do
      within("#edit_customer_#{customer.id}") do
        fill_in 'customer_first_name', with: "New"
      end
      expect { find("input[name=commit]").click }.to change(customer, :first_name).to("New")
    end
    it "last name" do
      within("#edit_customer_#{customer.id}") do
        fill_in 'customer_last_name', with: "New"
      end
      expect { find("input[name=commit]").click }.to change(customer, :last_name).to("New")
    end
    it "with blank" do
      within("#edit_customer_#{customer.id}") do
        fill_in 'customer_first_name', with: ""
        fill_in 'customer_last_name', with: ""
      end
      expect { find("input[name=commit]").click }.not_to change(customer, :last_name)
    end
  end

  it "load home" do
    click_link("edit_account")
    click_link("home")
    expect(page).to have_current_path(customer_root_path(event))
  end

  it "logout" do
    click_link("log_out")
    expect(page).to have_current_path(event_login_path(event))
  end

  it "download transactions" do
    click_link("download_transactions")
    expect(page).to have_current_path(event_credits_history_path(event, format: :pdf))
  end

  describe "change password" do
    it "correctly" do
      click_link("change_password")
      within("#edit_customer_#{customer.id}") do
        fill_in 'customer_password', with: "passw0rd"
        fill_in 'customer_password_confirmation', with: "passw0rd"
      end
      expect { find("input[name=commit]").click }.to change(customer, :encrypted_password)
    end

    it "with empty field" do
      click_link("change_password")
      within("#edit_customer_#{customer.id}") do
        fill_in 'customer_password', with: "passw0rd"
      end
      expect { find("input[name=commit]").click }.not_to change(customer, :encrypted_password)
    end

    it "with different password confirmation" do
      click_link("change_password")
      within("#edit_customer_#{customer.id}") do
        fill_in 'customer_password', with: "passw0rd"
        fill_in 'customer_password_confirmation', with: "diff3r3nt"
      end
      expect { find("input[name=commit]").click }.not_to change(customer, :encrypted_password)
    end

    it "with only letter" do
      click_link("change_password")
      within("#edit_customer_#{customer.id}") do
        fill_in 'customer_password', with: "password"
        fill_in 'customer_password_confirmation', with: "password"
      end
      expect { find("input[name=commit]").click }.not_to change(customer, :encrypted_password)
    end

    it "with only numbers" do
      click_link("change_password")
      within("#edit_customer_#{customer.id}") do
        fill_in 'customer_password', with: "1234567"
        fill_in 'customer_password_confirmation', with: "1234567"
      end
      expect { find("input[name=commit]").click }.not_to change(customer, :encrypted_password)
    end
  end
end
