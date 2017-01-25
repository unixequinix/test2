require "spec_helper"

RSpec.feature "Ticket Assignation", type: :feature do
  let(:admin) { create(:admin, password: "test", password_confirmation: "test") }

  describe "User wants to log in" do
    before { visit(new_admin_session_path) }

    context "with valid credentials" do
      before do
        find("#admin_email").set(admin.email)
        find("#admin_password").set("test")
        find(".btn-login").click
      end

      it "renders correctly" do
        expect(page.status_code).to eq(200)
      end

      it "gets redirected to events listings page" do
        expect(page.current_path).to eq(admin_root_path)
      end
    end

    context "with invalid credentials" do
      before do
        find("#admin_email").set(admin.email)
        find("#admin_password").set("wrong")
        find(".btn-login").click
      end

      it "renders correctly" do
        expect(page.status_code).to eq(200)
      end

      it "gets redirected to events listings page" do
        expect(page.current_path).to eq(new_admin_session_path)
      end
    end
  end
end
