require "rails_helper"

RSpec.feature "Admin Ticket assignation", type: :feature do
  context "with account signed in" do
    describe "an admin " do
      before do
        event = create(:event)
        customer = create(:customer, event: event)
        admin = create(:admin)
        @ticket = create(:ticket, event: event)

        login_as(admin, scope: :admin)
        create(:station, category: "customer_portal", event: event)

        visit "/admins/events/#{event.slug}/customers"
        click_link(customer.email)
        find("a", text: t("admin.actions.assign_ticket")).click
      end

      after do
        click_on(t("ticket_assignations.button"))
        expect(page.body).not_to include(@ticket.code)
      end

      it "should be able to assign a valid ticket" do
        fill_in("Event Ticket Code Number", with: @ticket.code)
      end

      it "shouldn't be able to assign an invalid ticket" do
        fill_in("Event Ticket Code Number", with: "invalid number")
      end
    end
  end
end
