require "spec_helper"

RSpec.describe Companies::Api::V1::TicketTypesController, type: :controller do
  let(:event) { create(:event) }
  let(:company) { create(:company, event: event) }
  let(:ticket_type) { create(:ticket_type, event: event, company: company) }

  describe "GET index" do
    context "when authenticated" do
      before { http_login(event.token, company.access_token) }

      it "returns 200 status code" do
        get :index, params: { event_id: event }
        expect(response).to be_ok
      end

      it "returns only the ticket types for that company" do
        get :index, params: { event_id: event }

        body = JSON.parse(response.body)
        db_ttypes = body["ticket_types"].map { |m| m["name"] }

        expect(company.ticket_types).to match_array(db_ttypes.map(&:name))
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

      context "when the ticket type belongs to the company" do
        before { get :show, params: { event_id: event, id: ticket_type } }

        it "returns a 200 status code" do
          expect(response).to be_ok
        end

        it "returns the correct ticket type" do
          body = JSON.parse(response.body)
          expect(body["name"]).to eq(TicketType.find(ticket_type.id).name)
        end
      end

      context "when the ticket type doesn't belong to the company" do
        it "returns a 404 status code" do
          get :show, params: { event_id: event, id: create(:ticket_type) }
          expect(response.status).to eq(404)
        end
      end
    end

    context "when not authenticated" do
      it "returns a 401 status code" do
        get :show, params: { event_id: event, id: ticket_type }
        expect(response).to be_unauthorized
      end
    end
  end

  describe "POST create" do
    context "when authenticated" do
      before { http_login(event.token, company.access_token) }

      context "when the request is valid" do
        it "increases the tickets in the database by 1" do
          expect do
            post :create, params: { ticket_type: attributes_for(:ticket_type) }
          end.to change(TicketType, :count).by(1)
        end

        it "returns a 201 status code" do
          post :create, params: { ticket_type: attributes_for(:ticket_type) }
          expect(response.status).to eq(201)
        end

        it "returns the created ticket type" do
          atts = attributes_for(:ticket_type)
          post :create, params: { ticket_type: atts }

          body = JSON.parse(response.body)
          expect(body["name"]).to eq(atts[:name])
        end
      end

      context "when the request is invalid" do
        it "returns a 422 status code" do
          post :create, params: { ticket_type: { with: "Invalid attributes" } }
          expect(response.status).to eq(422)
        end
      end
    end

    context "when not authenticated" do
      it "returns a 401 status code" do
        post :create, params: { ticket_type: { with: "Some data" } }
        expect(response).to be_unauthorized
      end
    end
  end

  describe "PATCH update" do
    context "when authenticated" do
      before { http_login(event.token, company.access_token) }

      context "when the request is valid" do
        let(:new_params) { { name: "New ticket type" } }

        it "changes ticket type's attributes" do
          put :update, params: { id: ticket_type, ticket_type: new_params }
          ticket_type.reload
          expect(ticket_type.name).to eq("New ticket type")
        end

        it "returns a 200 code status" do
          put :update, params: { id: ticket_type, ticket_type: new_params }
          expect(response).to be_ok
        end

        it "returns the updated ticket" do
          put :update, params: { id: ticket_type, ticket_type: new_params }
          body = JSON.parse(response.body)
          ticket_type.reload
          expect(body["name"]).to eq(ticket_type.name)
        end
      end

      context "when the request is invalid" do
        it "returns a 422 status code" do
          put :update, params: { id: ticket_type, ticket_type: { name: nil, ticket_type_ref: "AA123" } }
          expect(response.status).to eq(422)
        end

        it "doesn't change ticket's attributes" do
          put :update, params: { id: ticket_type, ticket_type: { name: nil, ticket_type_ref: "AA123" } }
          ticket_type.reload
          expect(ticket_type.company_code).not_to eq("AA123")
        end
      end
    end

    context "when not authenticated" do
      it "returns a 401 status code" do
        put :update, params: { id: ticket_type, ticket_type: { name: "AA123" } }
        expect(response).to be_unauthorized
      end
    end
  end
end
