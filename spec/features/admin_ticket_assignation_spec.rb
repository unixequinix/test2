require "rails_helper"

RSpec.feature "Admin Gtag assignation", type: :feature do

  context "with account signed in" do
    before :each do
      admin = create(:admin)
      login_as(admin, scope: :admin)
    end

    describe "a customer " do
      before :each do
        @gtag = create(:gtag, event: @event)
      end

      it "should be able to assign a gtag" do
        visit "/#{@event_creator.event.slug}/gtag_registrations/new"
        within("form") do
          fill_in(t("gtag_registrations.placeholders.#{@gtag_format}.line_1"), with: @gtag.tag_serial_number)
          fill_in(t("gtag_registrations.placeholders.#{@gtag_format}.line_2"), with: @gtag.tag_uid)
        end
        click_button(t('gtag_registrations.button'))
        expect(current_path).to eq("/#{@event_creator.event.slug}")
      end
    end
  end
end
