require "spec_helper"

RSpec.describe Companies::Api::V1::BannedTicketsController, type: :controller do
  let(:event) { create(:event) }
  let(:ticket_type) { create(:ticket_type, event: event) }
  let(:agreement) { ticket_type.company_event_agreement }
  let(:company) { agreement.company }
  before { create_list(:ticket, 2, banned: true, event: event, ticket_type: ticket_type) }

  describe "GET index" do
    context "when authenticated" do
      before { http_login(event.token, company.access_token) }

      it "returns 200 status code" do
        get :index, params: { event_id: event.id }
        expect(response).to be_ok
      end

      it "returns only the banned tickets for that company" do
        get :index, params: { event_id: event.id }

        body = JSON.parse(response.body)
        tickets = body["blacklisted_tickets"].map { |m| m["ticket_reference"] }

        db_tickets = event.tickets.where(banned: true)
                          .joins(ticket_type: :company_event_agreement)
                          .where(company_event_agreements: { id: agreement.id })

        expect(tickets).to match_array(db_tickets.map(&:code))
      end
    end

    context "when not authenticated" do
      it "returns a 401 status code" do
        get :index, params: { event_id: event.id }
        expect(response).to be_unauthorized
      end
    end
  end

  describe "POST create" do
    context "when authenticated" do
      before { http_login(event.token, company.access_token) }

      context "when the request is valid" do
        let(:ticket) { create(:ticket, event: event, ticket_type: ticket_type) }
        before { post :create, params: { tickets_blacklist: { ticket_reference: ticket.code } } }

        it "bans the ticket" do
          expect(ticket.reload).to be_banned
        end

        it "returns a 201 status code" do
          expect(response.status).to eq(201)
        end

        it "returns the banned ticket" do
          body = JSON.parse(response.body)
          expect(body["ticket_reference"]).to eq(ticket.code)
        end
      end

      context "when the request is invalid" do
        it "returns a 400 status code" do
          post :create, params: { tickets_blacklist: { with: "Invalid request" } }
          expect(response.status).to eq(400)
        end
      end
    end

    context "when not authenticated" do
      it "returns a 401 status code" do
        post :create, params: { tickets_blacklist: { with: "Some data" } }
        expect(response).to be_unauthorized
      end
    end
  end

  describe "DELETE destroy" do
    let(:ticket) { create(:ticket, banned: true, event: event, ticket_type: ticket_type) }

    context "when authenticated" do
      before(:each) { http_login(event.token, company.access_token) }

      context "when the request is valid" do
        before { delete :destroy, params: { id: ticket.code } }

        it "unbans the ticket" do
          expect(ticket.reload).not_to be_banned
        end

        it "returns a 204 code status" do
          expect(response.status).to eq(204)
        end
      end

      context "when the request is invalid" do
        it "returns a 404 status code" do
          delete :destroy, params: { id: "InvalidTicketReference" }
          expect(response.status).to eq(404)
        end
      end
    end

    context "when not authenticated" do
      it "returns a 401 status code" do
        delete :destroy, params: { id: ticket.code, ticket: { without: "Authenticate" } }
        expect(response).to be_unauthorized
      end
    end
  end
end
