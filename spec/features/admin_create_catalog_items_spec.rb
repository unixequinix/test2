require "rails_helper"

RSpec.feature "Admin create catalog items", type: :feature do
  context "with an admin signed in" do
    before :each do
      @event = create(:event)
      admin = create(:admin)
      login_as(admin, scope: :admin)
    end

    it "should be able to create a credit" do
      visit "/admins/events/#{@event.slug}/credits"
      within(".action-bar-btns") do
        click_link(t("admin.actions.new"))
      end
      fill_in(t("admin.catalog_item.name"), with: "A name")
      fill_in(t("admin.catalog_item.description"), with: "An interesting description")
      fill_in(t("admin.catalog_item.initial_amount"), with: "0")
      fill_in(t("admin.catalog_item.step"), with: "1")
      fill_in(t("admin.catalog_item.min_purchasable"), with: "0")
      fill_in(t("admin.catalog_item.max_purchasable"), with: "10")
      fill_in(t("admin.credits.value"), with: "10")
      fill_in(t("admin.credits.currency"), with: "EUR")
      click_on(t("helpers.submit.create", model: "credit"))
      expect(page.body).to include(t("alerts.created"))
    end

    it "should be able to create an access" do
      visit "/admins/events/#{@event.slug}/accesses"
      within(".action-bar-btns") do
        click_link(t("admin.actions.new"))
      end
      fill_in(t("admin.catalog_item.name"), with: "A name")
      fill_in(t("admin.catalog_item.description"), with: "An interesting description")
      fill_in(t("admin.catalog_item.initial_amount"), with: "0")
      fill_in(t("admin.catalog_item.step"), with: "1")
      fill_in(t("admin.catalog_item.min_purchasable"), with: "0")
      fill_in(t("admin.catalog_item.max_purchasable"), with: "10")
      click_on((t("helpers.submit.create", model: "Access")))
      expect(page.body).to include(t("alerts.created"))
    end

    it "should be able to create a voucher" do
      visit "/admins/events/#{@event.slug}/vouchers"
      within(".action-bar-btns") do
        click_link(t("admin.actions.new"))
      end
      fill_in(t("admin.catalog_item.name"), with: "A name")
      fill_in(t("admin.catalog_item.description"), with: "An interesting description")
      fill_in(t("admin.catalog_item.initial_amount"), with: "0")
      fill_in(t("admin.catalog_item.step"), with: "1")
      fill_in(t("admin.catalog_item.min_purchasable"), with: "0")
      fill_in(t("admin.catalog_item.max_purchasable"), with: "10")
      click_on((t("helpers.submit.create", model: "Voucher")))
      expect(page.body).to include(t("alerts.created"))
    end
  end
end
