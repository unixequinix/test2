require "rails_helper"

RSpec.describe Companies::Api::V1::BannedTicketsController, type: :controller do
  let(:event) { create(:event) }
  let(:company) { create(:company) }
  let(:agreement) { create(:company_event_agreement, event: event, company: company) }
  let(:t_type) { create(:company_ticket_type, event: event, company_event_agreement: agreement) }
  before { create_list(:ticket, 2, banned: true, event: event, company_ticket_type: t_type) }

  describe "GET index" do
    context "when authenticated" do
      before(:each) do
        http_login(event.token, company.access_token)
      end

      it "returns 200 status code" do
        get :index, event_id: event.id
        expect(response.status).to eq(200)
      end

      it "returns only the banned tickets for that company" do
        get :index, event_id: event.id

        body = JSON.parse(response.body)
        tickets = body["blacklisted_tickets"].map { |m| m["ticket_reference"] }

        db_tickets = event.tickets.where(banned: true)
                          .joins(company_ticket_type: :company_event_agreement)
                          .where(company_event_agreements: { id: agreement.id })

        expect(tickets).to match_array(db_tickets.map(&:code))
      end
    end

    context "when not authenticated" do
      it "returns a 401 status code" do
        get :index, event_id: event.id
        expect(response.status).to eq(401)
      end
    end
  end

  describe "POST create" do
    context "when authenticated" do
      before(:each) do
        http_login(event.token, company.access_token)
      end

      context "when the request is valid" do
        let(:ticket) { create(:ticket, :with_purchaser, event: event, company_ticket_type: t_type) }

        it "bans the ticket" do
          post :create, tickets_blacklist: { ticket_reference: ticket.code }
          expect(ticket.reload).to be_banned
        end

        it "returns a 201 status code" do
          post :create, tickets_blacklist: { ticket_reference: ticket.code }
          expect(response.status).to eq(201)
        end

        it "returns the banned ticket" do
          post :create, tickets_blacklist: { ticket_reference: ticket.code }

          body = JSON.parse(response.body)
          expect(body["ticket_reference"]).to eq(ticket.code)
        end
      end

      context "when the request is invalid" do
        it "returns a 400 status code" do
          post :create, tickets_blacklist: { with: "Invalid request" }
          expect(response.status).to eq(400)
        end
      end
    end

    context "when not authenticated" do
      it "returns a 401 status code" do
        post :create, tickets_blacklist: { with: "Some data" }
        expect(response.status).to eq(401)
      end
    end
  end

  describe "DELETE destroy" do
    let(:ticket) { create(:ticket, banned: true, event: event, company_ticket_type: t_type) }

    context "when authenticated" do
      before(:each) { http_login(event.token, company.access_token) }

      context "when the request is valid" do
        it "unbans the ticket" do
          delete :destroy, id: ticket.code
          expect(ticket.reload).not_to be_banned
        end

        it "returns a 204 code status" do
          delete :destroy, id: ticket.code
          expect(response.status).to eq(204)
        end
      end

      context "when the request is invalid" do
        it "returns a 404 status code" do
          delete :destroy, id: "InvalidTicketReference"
          expect(response.status).to eq(404)
        end
      end
    end

    context "when not authenticated" do
      it "returns a 401 status code" do
        delete :destroy, id: ticket.code, ticket: { without: "Authenticate" }
        expect(response.status).to eq(401)
      end
    end
  end
end
