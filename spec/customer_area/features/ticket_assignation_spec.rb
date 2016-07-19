require "rails_helper"

RSpec.feature "Ticket Assignation", type: :feature do
  let(:event) { create(:event, :ticket_assignation, :pre_event) }
  let(:customer) { create(:customer, event: event) }
  let(:valid_ticket) { create(:ticket, event: event) }
  let(:invalid_ticket) { create(:ticket, :assigned, event: event) }
  let(:event_path) { customer_root_path(event) }

  describe "User wants to assign a ticket" do
    before do
      login_as(customer, scope: :customer)
      visit(event_path)
    end

    context "when ticket is valid and unregistered" do
      before do
        find(".cb-add_ticket").click
        find(".cb-ticket_field").set(valid_ticket.code)
        find(".cb-ticket_submit").click
      end

      it "assigns the ticket" do
        customer_ticket = customer.profile.active_tickets_assignment.first.credentiable
        expect(customer_ticket.code).to eq(valid_ticket.code)
      end

      it "redirects to customer portal home page" do
        eventually { expect(current_path).to eq(event_path) }
      end
    end

    context "when ticket is already registered" do
      before do
        find(".cb-add_ticket").click
        find(".cb-ticket_field").set(invalid_ticket.code)
        find(".cb-ticket_submit").click
      end

      it "doesn't assign the ticket" do
        expect(customer.profile).to be_nil
          eventually { expect(page.body).to have_css(".msg-for-error") }
      end

      it "renders the same page" do
        eventually { expect(current_path).to eq(current_path) }
      end
    end

    context "when ticket is blank" do
      before do
        find(".cb-add_ticket").click
        find(".cb-ticket_submit").click
      end

      it "doesn't assign the ticket" do
        expect(customer.profile).to be_nil
        expect(page.body).to have_css(".msg-for-error")
      end

      it "renders the same page" do
        eventually { expect(current_path).to eq(current_path) }
      end
    end
  end
end
