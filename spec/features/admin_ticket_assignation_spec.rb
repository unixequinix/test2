require "rails_helper"

RSpec.feature "Admin Ticket assignation", type: :feature do

  context "with account signed in" do
    before :all do
      @event_creator = EventCreator.new(build(:event,gtag_registration: true).to_hash_parameters)
      @event_creator.save
      @event = @event_creator.event
      @customer = create(:customer, event: @event, confirmation_token: nil, confirmed_at: Time.now)

      admin = create(:admin)
      login_as(admin, scope: :admin)
    end

    describe "an admin " do
      before :each do
        @ticket = create(:ticket, event: @event)
      end

      it "should be able to assign a ticket" do
        visit "/admins/events/#{@event_creator.event.slug}/customers"
        within("[data-label='Email']") do
          click_link("a")
        end
        find('a', text:t("admin.actions.assign_ticket")).click
        fill_in("Event Ticket Barcode Number", with: @ticket.number)
        click_on(t('gtag_registrations.button'))
        expect(page.body).to include(@ticket.number)
      end
    end
  end
end

