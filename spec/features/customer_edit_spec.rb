require "spec_helper"

RSpec.feature "Edit customer", type: :feature do
  let(:event) { create(:event, :gtag_assignation, :pre_event) }
  let(:customer) { create(:customer, event: event) }
  let(:event_path) { customer_root_path(event) }
  let(:edit_path) { event_account_path(event) }
  let(:valid_data) { { email: "valid@email.com", first_name: "Glownet", last_name: "Glownet", current_password: "password" } }

  describe "User wants to edit his customer data in edit customer screen" do
    before do
      login_as(customer, scope: :customer)
      visit(edit_path)
    end

    context "when filling all fields correctly" do
      it "redirects to the main page" do
        valid_data.each do |f, v|
          find("#customer_#{f}").set(v)
        end
        click_button(I18n.t("registration.edit.button"))

        expect(current_path).to eq(event_path)
      end
    end

    context "when leaving a blank field" do
      it "an error is showed" do
        valid_data[:email] = ""
        valid_data.each do |f, v|
          find("#customer_#{f}").set(v)
        end
        click_button(I18n.t("registration.edit.button"))

        expect(page.body).to have_css(".error")
      end
    end
  end

  describe "User wants to change the password" do
    before do
      login_as(customer, scope: :customer)
      visit(edit_path)
    end

    context "when filling the fields correctly" do
      it "redirects to the main page" do
        find("#customer_current_password").set("password")
        find("#customer_password").set("new_password")
        find("#customer_password_confirmation").set("new_password")
        click_button(I18n.t("registration.edit.button"))

        expect(current_path).to eq(event_path)
      end
    end

    context "when current password is incorrect" do
      it "an error is showed" do
        find("#customer_current_password").set("")
        find("#customer_password").set("iconrrect_password")
        click_button(I18n.t("registration.edit.button"))

        expect(page.body).to have_css(".error")
      end
    end

    context "when current password is blank" do
      it "an error is showed" do
        find("#customer_current_password").set("")
        find("#customer_password").set("password")
        click_button(I18n.t("registration.edit.button"))

        expect(page.body).to have_css(".error")
      end
    end

    context "when password is blank" do
      it "password isn't changed" do
        expect do
          find("#customer_current_password").set("password")
          find("#customer_password").set("")
          click_button(I18n.t("registration.edit.button"))
        end.not_to change { customer.encrypted_password }
      end
    end
  end

  describe "User wants to change the email" do
    before do
      login_as(customer, scope: :customer)
      visit(edit_path)
    end

    context "when using a valid email" do
      it "redirects to the main page" do
        find("#customer_email").set("othervalidemail@example.com")
        find("#customer_current_password").set("password")
        click_button(I18n.t("registration.edit.button"))

        expect(current_path).to eq(event_path)
      end
    end

    context "when using an invalid email" do
      invalid_emails = [
        "plainaddress",
        '#@%^%#@#@#{$e}.com',
        "@example.com",
        "Joe Smith <email@example.com>",
        "email.example.com",
        "email@example@example.com",
        ".email@example.com",
        "email.@example.com",
        "email..email@example.com",
        "email@example.com (Joe Smith)",
        "email@-example.com",
        "email@111.222.333.44444",
        "email@example..com",
        "Abc..123@example.co"
      ]

      invalid_emails.each do |email|
        it "fails (email: #{email})" do
          find("#customer_email").set(email)
          find("#customer_current_password").set("password")
          click_button(I18n.t("registration.edit.button"))
          expect(page.body).to have_css(".error")
        end
      end
    end
  end
end
