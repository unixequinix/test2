require "rails_helper"

RSpec.feature "Admin create preevent items", type: :feature do
  context "with an admin signed in" do
    before :each do
      @event_creator = EventCreator.new(event_to_hash_parameters(build(:event)))
      @event_creator.save
      @event = @event_creator.event
      @customer = create(:customer, event: @event, confirmation_token: nil, confirmed_at: Time.now)

      admin = create(:admin)
      login_as(admin, scope: :admin)
      @gtag = create(:gtag, event: @event)
    end
    it "should be able to create a credit" do
      visit "/admins/events/#{@event_creator.event.slug}/credits"
      click_link(t("admin.actions.new"))
      fill_in(t("admin.preevent_item.name"), with: "A name")
      fill_in(t("admin.preevent_item.description"), with: "An interesting description")
      fill_in(t("admin.credits.value"), with: "10")
      fill_in(t("admin.credits.currency"), with: "EUR")
      within(".credit_standard") do
        choose("No")
      end
      click_on((t("helpers.submit.create", model: "credit")))
      expect(page.body).to include(t("alerts.created"))
    end
  end
end
