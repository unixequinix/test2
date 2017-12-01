require 'rails_helper'

RSpec.describe "Create a ticket", type: :feature do
  let(:user) { create(:user, role: :admin) }
  let(:event) { create(:event, state: "created") }

  before do
    @ticket_type = create(:ticket_type, event: event)

    login_as(user, scope: :user)
    visit admins_event_tickets_path(event)
    find("#floaty").click
    find_link("new_ticket_link").click
  end

  it "is located in tickets/new " do
    expect(page).to have_current_path(new_admins_event_ticket_path(event))
  end

  it "can be created by only filling code and ticket type" do
    expect do
      within("#new_ticket") do
        fill_in 'ticket_code', with: "TESTCODE"
        first('#ticket_ticket_type_id option', minimum: 1).select_option
      end

      find("input[name=commit]").click
    end.to change(Ticket, :count).by(1)

    expect(page).to have_current_path admins_event_ticket_path(event, Ticket.last.id)
  end

  it "can't be done without filling a ticket code" do
    expect do
      within("#new_ticket") do
        first('#ticket_ticket_type_id option', minimum: 1).select_option
      end

      find("input[name=commit]").click
    end.not_to change(Ticket, :count)

    expect(page).to have_current_path admins_event_tickets_path(event)
  end

  it "can be done filling everything" do
    expect do
      within("#new_ticket") do
        fill_in 'ticket_code', with: "TESTCODE"
        first('#ticket_ticket_type_id option', minimum: 1).select_option
        fill_in 'ticket_purchaser_first_name', with: "purchasername"
        fill_in 'ticket_purchaser_last_name', with: "purchasersurname"
        fill_in 'ticket_purchaser_email', with: "purchaser@email.com"
      end

      find("input[name=commit]").click
    end.to change(Ticket, :count).by(1)

    ticket = event.tickets.find_by(code: "TESTCODE")
    expect(page).to have_current_path(admins_event_ticket_path(event, ticket.id))

    expect(ticket.purchaser_first_name).to eq("purchasername")
    expect(ticket.purchaser_last_name).to eq("purchasersurname")
    expect(ticket.purchaser_email).to eq("purchaser@email.com")
    expect(ticket.ticket_type).to eq(@ticket_type)
  end
end
