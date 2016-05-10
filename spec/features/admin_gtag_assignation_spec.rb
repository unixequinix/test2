require "rails_helper"

RSpec.feature "Admin Gtag assignation", type: :feature do
  context "with an admin signed in" do
    before :each do
      Seeder::SeedLoader.create_stations
      @event_creator = EventCreator.new(event_to_hash_parameters(build(:event)))
      @event_creator.save
      @event = @event_creator.event
      @customer = create(:customer, event: @event)
      @gtag = create(:gtag, event: @event)
      admin = create(:admin)
      login_as(admin, scope: :admin)
    end

    it "should be able to assign a valid gtag" do
      visit "/admins/events/#{@event_creator.event.slug}/customers"
      click_link(@customer.email)
      find("a", text: t("admin.actions.assign_gtag")).click
      fill_in(t("gtag_assignations.placeholders.standard.line_2"), with: @gtag.tag_uid)
      click_on(t("gtag_assignations.button"))
      expect(page.body).to include(@gtag.tag_uid)
    end

    it "shouldn't be able to assign an invalid gtag" do
      visit "/admins/events/#{@event_creator.event.slug}/customers"
      click_link(@customer.email)
      find("a", text: t("admin.actions.assign_gtag")).click
      fill_in(t("gtag_assignations.placeholders.standard.line_2"), with: "invalid uid")
      click_on(t("gtag_assignations.button"))
      expect(page.body).not_to include(@gtag.tag_uid)
    end
  end
end
