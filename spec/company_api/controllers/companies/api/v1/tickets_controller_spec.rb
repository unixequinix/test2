require "rails_helper"

RSpec.describe Companies::Api::V1::TicketsController, type: :controller do
  before(:all) do
    @event = create(:event)
    @company = create(:company)
    @agreement = create(:company_event_agreement, event: @event, company: @company)
    ticket_type = create(:company_ticket_type, event: @event, company_event_agreement: @agreement)

    create_list(:ticket, 2, :with_purchaser, event: @event, company_ticket_type: ticket_type)
  end

  describe "GET index" do
    context "when authenticated" do
      before(:each) do
        @company = Company.last
        http_login(@event.token, @company.access_token)
      end

      it "returns 200 status code" do
        get :index, event_id: @event.id

        expect(response.status).to eq(200)
      end

      it "returns only the tickets for that company" do
        get :index, event_id: @event.id

        body = JSON.parse(response.body)
        tickets = body["tickets"].map { |m| m["ticket_reference"] }

        db_tickets = Ticket.joins(company_ticket_type: :company_event_agreement)
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

  describe "GET show" do
    context "when authenticated" do
      before(:each) do
        @company = Company.last
        http_login(@event.token, @company.access_token)
      end

      context "when the ticket belongs to the company" do
        before(:each) do
          get :show, event_id: @event.id, id: Ticket.last.id
        end

        it "returns a 200 status code" do
          expect(response.status).to eq(200)
        end

        it "returns the correct ticket" do
          body = JSON.parse(response.body)
          expect(body["ticket_reference"]).to eq(Ticket.last.code)
        end
      end

      context "when the ticket doesn't belong to the company" do
        it "returns a 404 status code" do
          get :show, event_id: @event.id, id: create(:ticket)
          expect(response.status).to eq(404)
        end
      end
    end

    context "when not authenticated" do
      it "returns a 401 status code" do
        get :show, event_id: @event.id, id: Ticket.last.id

        expect(response.status).to eq(401)
      end
    end
  end

  describe "POST create" do
    context "when authenticated" do
      before(:each) do
        @company = Company.last
        http_login(@event.token, @company.access_token)
      end

      context "when the request is valid" do
        let(:params) do
          {
            ticket_reference: "t1ck3tt3st",
            ticket_type_id: CompanyTicketType.last.id,
            purchaser_attributes: {
              first_name: "Glownet",
              last_name: "Glownet",
              email: "hi@glownet.com"
            }
          }
        end

        it "increases the tickets in the database by 1" do
          expect do
            post :create, ticket: params
          end.to change(Ticket, :count).by(1)
        end

        it "returns a 201 status code" do
          post :create, ticket: params
          expect(response.status).to eq(201)
        end

        it "returns the created ticket" do
          post :create, ticket: params

          body = JSON.parse(response.body)
          expect(body["ticket_reference"]).to eq(Ticket.last.code)
          expect(body["purchaser_email"]).to eq(Ticket.last.purchaser.email)
        end
      end

      context "when the request is invalid" do
        it "returns a 400 status code" do
          post :create, ticket: { with: "Invalid request" }
          expect(response.status).to eq(400)
        end
      end
    end

    context "when not authenticated" do
      it "returns a 401 status code" do
        post :create, ticket: { with: "Some data" }
        expect(response.status).to eq(401)
      end
    end
  end

  describe "PATCH update" do
    context "when authenticated" do
      before(:each) do
        @company = Company.last
        @ticket = Ticket.last
        http_login(@event.token, @company.access_token)
      end

      context "when the request is valid" do
        let(:params) do
          { ticket_reference: "n3wt1cketr3fer3nc3",
            purchaser_attributes: { email: "updated@email.com" } }
        end

        it "changes ticket's attributes" do
          put :update, id: @ticket, ticket: params
          @ticket.reload
          expect(@ticket.code).to eq("n3wt1cketr3fer3nc3")
          expect(@ticket.purchaser.email).to eq("updated@email.com")
        end

        it "returns a 200 code status" do
          put :update, id: @ticket, ticket: params
          expect(response.status).to eq(200)
        end

        it "returns the updated ticket" do
          put :update, id: @ticket, ticket: params
          body = JSON.parse(response.body)
          @ticket.reload
          expect(body["ticket_reference"]).to eq(@ticket.code)
        end
      end

      context "when the request is invalid" do
        let(:params) do
          { ticket_reference: nil,
            purchaser_attributes: { email: "newemail@glownet.com" } }
        end

        it "returns a 400 status code" do
          put :update, id: @ticket, ticket: params
          expect(response.status).to eq(400)
        end

        it "doesn't change ticket's attributes" do
          put :update, id: @ticket, ticket: params
          @ticket.reload
          expect(@ticket.purchaser.email).not_to eq("newemail@glownet.com")
        end
      end
    end

    context "when not authenticated" do
      it "returns a 401 status code" do
        put :update, id: Ticket.last, ticket: { without: "Authenticate" }
        expect(response.status).to eq(401)
      end
    end
  end
end
