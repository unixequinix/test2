require "rails_helper"

RSpec.describe Companies::Api::V1::BannedTicketsController, type: :controller do
  before(:all) do
    @event = create(:event)
    @company = create(:company)
    @agreement = create(:company_event_agreement, event: @event, company: @company)
    @ticket_type = create(:company_ticket_type, event: @event, company_event_agreement: @agreement)

    create_list(:ticket, 2, :banned, event: @event, company_ticket_type: @ticket_type)
  end
  describe "GET index" do
    context "when authenticated" do
      before(:each) do
        http_login(@event.token, @company.access_token)
      end

      it "returns 200 status code" do
        get :index, event_id: @event.id

        expect(response.status).to eq(200)
      end

      it "returns only the banned tickets for that company" do
        get :index, event_id: @event.id

        body = JSON.parse(response.body)
        tickets = body["blacklisted_tickets"].map { |m| m["ticket_reference"] }

        db_tickets = Ticket.banned
                      .joins(company_ticket_type: :company_event_agreement)
                      .where(event: @event, company_event_agreements: { id: @agreement.id })


        expect(tickets).to match_array(db_tickets.map(&:code))
      end
    end

    context "when not authenticated" do
      it "returns a 401 status code" do
        get :index, event_id: @event.id

        expect(response.status).to eq(401)
      end
    end
  end

  describe "POST create" do
    context "when authenticated" do
      before(:each) do
        http_login(@event.token, @company.access_token)
      end

      context "when the request is valid" do
        before(:each) do
          @ticket = create(:ticket,
                           :with_purchaser,
                           event: @event,
                           company_ticket_type: @ticket_type)
        end

        it "increases the banned tickets in the database by 1" do
          expect do
            post :create, tickets_blacklist: { ticket_reference: @ticket.code }
          end.to change(BannedTicket, :count).by(1)
        end

        it "returns a 201 status code" do
          post :create, tickets_blacklist: { ticket_reference: @ticket.code }
          expect(response.status).to eq(201)
        end

        it "returns the banned ticket" do
          post :create, tickets_blacklist: { ticket_reference: @ticket.code }

          body = JSON.parse(response.body)
          expect(body["ticket_reference"]).to eq(Ticket.banned.last.code)
        end
      end

      context "when the request is invalid" do
        it "returns a 400 status code" do
          post :create, tickets_blacklist: { with: "Invalid request" }
          expect(response.status).to eq(404)
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
    before(:each) do
      @ticket = create(:ticket, :banned, code: "Glownet",
                                         event: @event,
                                         company_ticket_type: @ticket_type)
    end

    context "when authenticated" do
      before(:each) do
        http_login(@event.token, @company.access_token)
      end

      context "when the request is valid" do
        it "removes the ticket from the banned table" do
          delete :destroy, id: @ticket.code
          expect(Ticket.banned.last.code).not_to eq("Glownet")
        end

        it "returns a 204 code status" do
          put :destroy, id: @ticket.code
          expect(response.status).to eq(204)
        end
      end

      context "when the request is invalid" do
        it "returns a 404 status code" do
          put :destroy, id: "InvalidTicketReference"
          expect(response.status).to eq(404)
        end
      end
    end

    context "when not authenticated" do
      it "returns a 401 status code" do
        put :destroy, id: Ticket.banned.last.code, ticket: { without: "Authenticate" }
        expect(response.status).to eq(401)
      end
    end
  end
end
