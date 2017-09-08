require 'rails_helper'

RSpec.describe Api::V2::Events::TicketsController, type: %i[controller api] do
  let(:event) { create(:event, open_api: true, state: "created") }
  let(:user) { create(:user) }
  let(:ticket_type) { create(:ticket_type, event: event) }
  let(:ticket) { create(:ticket, event: event, ticket_type: ticket_type) }

  let(:invalid_attributes) { { code: nil } }
  let(:valid_attributes) { { code: "2221212212121", ticket_type_id: ticket_type.id } }

  before { token_login(user, event) }

  describe "GET #index" do
    before { create_list(:ticket, 10, event: event) }

    it "returns a success response" do
      get :index, params: { event_id: event.id }
      expect(response).to have_http_status(:ok)
    end

    it "returns all tickets" do
      get :index, params: { event_id: event.id }
      expect(json.size).to be(10)
    end

    it "does not return tickets from another event" do
      new_ticket = create(:ticket)
      get :index, params: { event_id: event.id }
      expect(json).not_to include(obj_to_json(new_ticket, "TicketSerializer"))
    end
  end

  describe "GET #show" do
    it "returns a success response" do
      get :show, params: { event_id: event.id, id: ticket.to_param }
      expect(response).to have_http_status(:ok)
    end

    it "returns the ticket as JSON" do
      get :show, params: { event_id: event.id, id: ticket.to_param }
      expect(json).to eq(obj_to_json(ticket, "TicketSerializer"))
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new Ticket" do
        expect do
          post :create, params: { event_id: event.id, ticket: valid_attributes }
        end.to change(Ticket, :count).by(1)
      end

      it "returns a created response" do
        post :create, params: { event_id: event.id, ticket: valid_attributes }
        expect(response).to be_created
      end

      it "returns the created ticket" do
        post :create, params: { event_id: event.id, ticket: valid_attributes }
        expect(json["id"]).to eq(Ticket.last.id)
      end
    end

    context "with invalid params" do
      it "returns an unprocessable_entity response" do
        post :create, params: { event_id: event.id, ticket: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      let(:new_attributes) { { code: "1111111111" } }

      before { ticket }

      it "updates the requested ticket" do
        expect do
          put :update, params: { event_id: event.id, id: ticket.to_param, ticket: new_attributes }
        end.to change { ticket.reload.code }.to("1111111111")
      end

      it "returns the ticket" do
        put :update, params: { event_id: event.id, id: ticket.to_param, ticket: valid_attributes }
        expect(json["id"]).to eq(ticket.id)
      end
    end

    context "with invalid params" do
      it "returns an unprocessable_entity response" do
        put :update, params: { event_id: event.id, id: ticket.to_param, ticket: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "DELETE #destroy" do
    before { ticket }

    it "destroys the requested ticket" do
      expect do
        delete :destroy, params: { event_id: event.id, id: ticket.to_param }
      end.to change(Ticket, :count).by(-1)
    end

    it "returns a success response" do
      delete :destroy, params: { event_id: event.id, id: ticket.to_param }
      expect(response).to have_http_status(:ok)
    end
  end
end
