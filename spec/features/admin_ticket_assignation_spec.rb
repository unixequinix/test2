require "rails_helper"

RSpec.feature "Admin Ticket assignation", type: :feature do
  context "with account signed in" do
    describe "an admin " do
      before :each do
        @event = build(:event)
        @customer = create(:customer, event: @event)
        @ticket = create(:ticket, event: @event)
        admin = create(:admin)
        login_as(admin, scope: :admin)
      end

      it "should be able to assign a valid ticket" do
        visit "/admins/events/#{@event.slug}/customers"
        click_link(@customer.email)
        find("a", text: t("admin.actions.assign_ticket")).click
        fill_in("Event Ticket Code Number", with: @ticket.code)
        click_on(t("ticket_assignations.button"))
        expect(page.body).to include(@ticket.code)
      end

      it "shouldn't be able to assign an invalid ticket" do
        visit "/admins/events/#{@event.slug}/customers"
        click_link(@customer.email)
        find("a", text: t("admin.actions.assign_ticket")).click
        fill_in("Event Ticket Code Number", with: "invalid number")
        click_on(t("ticket_assignations.button"))
        expect(page.body).not_to include(@ticket.code)
      end
    end
  end
end
