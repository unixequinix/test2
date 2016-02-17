require "rails_helper"

RSpec.feature "Admin Gtag assignation", type: :feature do
  context "with an admin signed in" do
    before :each do
      @event = create(:event)
      @customer = create(:customer, event: @event, confirmation_token: nil, confirmed_at: Time.now)
      @gtag = create(:gtag, event: @event)
      admin = create(:admin)
      login_as(admin, scope: :admin)
    end
    it "should be able to assign a valid gtag" do
      visit "/admins/events/#{@event.slug}/customers"
      click_link(@customer.email)
      find("a", text: t("admin.actions.assign_gtag")).click
      fill_in(t("gtag_assignations.placeholders.standard.line_1"), with: @gtag.tag_serial_number)
      fill_in(t("gtag_assignations.placeholders.standard.line_2"), with: @gtag.tag_uid)
      click_on(t("gtag_assignations.button"))
      expect(page.body).to include(@gtag.tag_uid)
    end

    it "shouldn't be able to assign an invalid gtag" do
      visit "/admins/events/#{@event.slug}/customers"
      click_link(@customer.email)
      find("a", text: t("admin.actions.assign_gtag")).click
      fill_in(t("gtag_assignations.placeholders.standard.line_1"), with: "invalid serial number")
      fill_in(t("gtag_assignations.placeholders.standard.line_2"), with: "invalid uid")
      click_on(t("gtag_assignations.button"))
      expect(page.body).not_to include(@gtag.tag_uid)
    end
  end
end
