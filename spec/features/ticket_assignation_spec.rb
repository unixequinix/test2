require "spec_helper"

RSpec.feature "Ticket Assignation", type: :feature do
  let(:event) { create(:event, :ticket_assignation, :pre_event) }
  let(:customer) { create(:customer, event: event) }
  let(:valid_ticket) { create(:ticket, event: event) }
  let(:invalid_ticket) { create(:ticket, event: event, customer: create(:customer)) }
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
        codes = customer.reload.tickets.pluck(:code)
        expect(codes).to include(valid_ticket.code)
        expect(page.body).to include(valid_ticket.code)
      end

      it "redirects to customer portal home page" do
        expect(current_path).to eq(event_path)
      end
    end

    context "when ticket is already registered" do
      before do
        find(".cb-add_ticket").click
        find(".cb-ticket_field").set(invalid_ticket.code)
        find(".cb-ticket_submit").click
      end

      it "doesn't assign the ticket" do
        expect(customer.tickets).not_to include(invalid_ticket)
        expect(page.body).to have_css(".error-message")
      end

      it "renders the same page" do
        expect(current_path).to eq(current_path)
      end
    end

    context "when ticket is blank" do
      before do
        find(".cb-add_ticket").click
        find(".cb-ticket_submit").click
      end

      it "doesn't assign the ticket" do
        expect(customer.tickets).to be_empty
        expect(page.body).to have_css(".error-message")
      end

      it "renders the same page" do
        expect(current_path).to eq(current_path)
      end
    end
  end

  describe "Ticket assignation availability" do
    before do
      login_as(customer, scope: :customer)
      visit(event_path)
    end

    context "when event status is preevent" do
      context "when ticket assignation is enabled" do
        it "is available" do
          expect(page.body).to include(I18n.t("dashboard.first_register.ticket"))
        end
      end

      context "when ticket assignation is disabled" do
        before do
          event.update!(ticket_assignation: false)
          visit(event_path)
        end

        it "is unavailable" do
          expect(page.body).not_to include(I18n.t("dashboard.first_register.ticket"))
        end
      end
    end

    context "when event status is during event" do
      before { event.update!(state: "started") }
      context "when ticket assignation is enabled" do
        it "is available" do
          expect(page.body).to include(I18n.t("dashboard.first_register.ticket"))
        end
      end

      context "when ticket assignation is disabled" do
        before do
          event.update!(ticket_assignation: false)
          visit(event_path)
        end

        it "is unavailable" do
          expect(page.body).not_to include(I18n.t("dashboard.first_register.ticket"))
        end
      end
    end

    context "when event status is finished" do
      before do
        event.update!(state: "finished")
        visit(event_path)
      end

      context "when ticket assignation is enabled" do
        it "is unavailable" do
          expect(page.body).not_to include(I18n.t("dashboard.first_register.ticket"))
        end
      end

      context "when ticket assignation is disabled" do
        before do
          event.update!(ticket_assignation: false)
          visit(event_path)
        end

        it "is unavailable" do
          expect(page.body).not_to include(I18n.t("dashboard.first_register.ticket"))
        end
      end
    end
  end
end
