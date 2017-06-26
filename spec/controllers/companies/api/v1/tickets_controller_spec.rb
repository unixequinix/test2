require "rails_helper"

RSpec.describe Companies::Api::V1::TicketsController, type: :controller do
  let(:event) { create(:event) }
  let(:company) { create(:company, event: event) }
  let(:ticket_type) { create(:ticket_type, event: event, company: company) }
  let(:tickets) { create_list(:ticket, 2, event: event, ticket_type: ticket_type) }

  describe "GET index" do
    context "when authenticated" do
      before do
        tickets
        http_login(event.token, company.access_token)
        get :index, params: { event_id: event }
      end

      it "returns 200 status code" do
        expect(response).to be_ok
      end

      it "returns only the tickets for that company" do
        get :index, params: { event_id: event }

        ws_tickets = JSON.parse(response.body)["tickets"].map { |m| m["ticket_reference"] }
        expect(tickets.map(&:code)).to match_array(ws_tickets)
      end
    end

    context "when not authenticated" do
      it "returns a 401 status code" do
        get :index, params: { event_id: event }
        expect(response).to be_unauthorized
      end
    end
  end

  describe "GET show" do
    context "when authenticated" do
      before { http_login(event.token, company.access_token) }

      context "when the ticket belongs to the company" do
        before { get :show, params: { event_id: event, id: tickets.first } }

        it "returns a 200 status code" do
          expect(response).to be_ok
        end

        it "returns the correct ticket" do
          body = JSON.parse(response.body)
          expect(body["ticket_reference"]).to eq(tickets.first.code)
        end
      end

      context "when the ticket doesn't belong to the company" do
        it "returns a 404 status code" do
          get :show, params: { event_id: event, id: create(:ticket) }
          expect(response.status).to eq(404)
        end
      end
    end

    context "when not authenticated" do
      it "returns a 401 status code" do
        get :show, params: { event_id: event, id: tickets.last }
        expect(response).to be_unauthorized
      end
    end
  end

  describe "POST create" do
    context "when authenticated" do
      before { http_login(event.token, company.access_token) }

      context "when the request is valid" do
        let(:params) do
          {
            ticket_reference: "t1ck3tt3st",
            ticket_type_id: ticket_type.id,
            purchaser_attributes: { first_name: "Glownet", last_name: "Glownet", email: "hi@glownet.com" }
          }
        end

        it "increases the tickets in the database by 1" do
          expect do
            post :create, params: { ticket: params }
          end.to change(Ticket, :count).by(1)
        end

        it "returns a 201 status code" do
          post :create, params: { ticket: params }
          expect(response.status).to eq(201)
        end

        it "returns the created ticket" do
          post :create, params: { ticket: params }

          body = JSON.parse(response.body)
          expect(body["ticket_reference"]).to eq(Ticket.last.code)
          expect(body["purchaser_email"]).to eq(Ticket.last.purchaser_email)
        end
      end

      context "when the request is invalid" do
        it "returns a 422 status code" do
          post :create, params: { ticket: { with: "Invalid request" } }
          expect(response.status).to eq(422)
        end
      end
    end

    context "when not authenticated" do
      it "returns a 401 status code" do
        post :create, params: { ticket: { with: "Some data" } }
        expect(response).to be_unauthorized
      end
    end
  end

  describe "POST bulk_upload" do
    let(:params) do
      [{
        ticket_reference: "11111",
        ticket_type_id: ticket_type.id,
        purchaser_attributes: { first_name: "Glownet", last_name: "Glownet", email: "hi@glownet.com" }
      },
       {
         ticket_reference: "22222",
         ticket_type_id: ticket_type.id,
         purchaser_attributes: { first_name: "Glownet", last_name: "Glownet", email: "hi@glownet.com" }
       }]
    end
    let(:invalid_params) do
      [{
        ticket_reference: "11111",
        purchaser_attributes: { first_name: "Glownet", last_name: "Glownet", email: "hi@glownet.com" }
      },
       {
         ticket_reference: "22222",
         ticket_type_id: ticket_type.id,
         purchaser_attributes: { first_name: "Glownet", last_name: "Glownet", email: "hi@glownet.com" }
       }]
    end
    context "when authenticated" do
      before { http_login(event.token, company.access_token) }

      context "when the request is valid" do
        it "increases the tickets in the database by 2" do
          expect do
            post :bulk_upload, params: { tickets: params }
          end.to change(Ticket, :count).by(2)
        end

        it "returns a 201 status code" do
          post :bulk_upload, params: { tickets: params }
          expect(response.status).to eq(201)
        end
      end

      context "when the request is invalid" do
        it "returns a 422 status code" do
          post :bulk_upload, params: { tickets: invalid_params }
          expect(response.status).to eq(422)
        end

        it "returns the array with errors" do
          post :bulk_upload, params: { tickets: invalid_params }
          body = JSON.parse(response.body)
          expect(body["errors"]).not_to be_empty
        end
      end
    end

    context "when not authenticated" do
      it "returns a 401 status code" do
        post :bulk_upload, params: { tickets: params }
        expect(response).to be_unauthorized
      end
    end
  end

  describe "PATCH update" do
    context "when authenticated" do
      before { http_login(event.token, company.access_token) }

      context "when the request is valid" do
        let(:params) do
          { ticket_reference: "n3wt1cketr3fer3nc3", purchaser_attributes: { email: "updated@email.com" } }
        end

        it "changes ticket's attributes" do
          put :update, params: { id: tickets.first, ticket: params }
          tickets.first.reload
          expect(tickets.first.code).to eq("n3wt1cketr3fer3nc3")
          expect(tickets.first.purchaser_email).to eq("updated@email.com")
        end

        it "returns a 200 code status" do
          put :update, params: { id: tickets.first, ticket: params }
          expect(response).to be_ok
        end

        it "returns the updated ticket" do
          put :update, params: { id: tickets.first, ticket: params }
          body = JSON.parse(response.body)
          tickets.first.reload
          expect(body["ticket_reference"]).to eq(tickets.first.code)
        end
      end

      context "when the request is invalid" do
        let(:params) do
          { ticket_reference: nil, purchaser_attributes: { email: "newemail@glownet.com" } }
        end

        it "returns a 422 status code" do
          put :update, params: { id: tickets.first, ticket: params }
          expect(response.status).to eq(422)
        end

        it "doesn't change ticket's attributes" do
          put :update, params: { id: tickets.first, ticket: params }
          tickets.first.reload
          expect(tickets.first.purchaser_email).not_to eq("newemail@glownet.com")
        end
      end
    end

    context "when not authenticated" do
      it "returns a 401 status code" do
        put :update, params: { id: tickets.first, ticket: { without: "Authenticate" } }
        expect(response).to be_unauthorized
      end
    end
  end
end
