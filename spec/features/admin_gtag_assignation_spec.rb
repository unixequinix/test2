require "rails_helper"

RSpec.feature "Admin Gtag assignation", type: :feature do
  context "with account signed in" do
    describe "an admin " do
      before :each do
        @event_creator = EventCreator.new(build(:event, gtag_registration: true).to_hash_parameters)
        @event_creator.save
        @event = @event_creator.event
        @customer = create(:customer, event: @event, confirmation_token: nil, confirmed_at: Time.now)

        admin = create(:admin)
        login_as(admin, scope: :admin)
        @gtag = create(:gtag, event: @event)
      end

      it "should be able to assign a valid gtag" do
        visit "/admins/events/#{@event_creator.event.slug}/customers"
        within("[data-label='Email']") do
          click_link("a")
        end
        find("a", text: t("admin.actions.assign_gtag")).click
        fill_in(t("gtag_registrations.placeholders.standard.line_1"), with: @gtag.tag_serial_number)
        fill_in(t("gtag_registrations.placeholders.standard.line_2"), with: @gtag.tag_uid)
        click_on(t("gtag_registrations.button"))
        expect(page.body).to include(@gtag.tag_uid)
      end

      it "shouldn't be able to assign an invalid gtag" do
        visit "/admins/events/#{@event_creator.event.slug}/customers"
        within("[data-label='Email']") do
          click_link("a")
        end
        find("a", text: t("admin.actions.assign_gtag")).click
        fill_in(t("gtag_registrations.placeholders.standard.line_1"), with: "invalid serial number")
        fill_in(t("gtag_registrations.placeholders.standard.line_2"), with: "invalid uid")
        click_on(t("gtag_registrations.button"))
        expect(page.body).not_to include(@gtag.tag_uid)
      end
    end
  end
end
