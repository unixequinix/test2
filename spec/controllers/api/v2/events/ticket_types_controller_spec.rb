require 'rails_helper'

RSpec.describe Api::V2::Events::TicketTypesController, type: %i[controller api] do
  let(:event) { create(:event, open_api: true, state: "created") }
  let(:user) { create(:user) }
  let(:company) { create(:company, event: event) }
  let(:ticket_type) { create(:ticket_type, event: event, company: company) }

  let(:invalid_attributes) { { name: nil } }
  let(:valid_attributes) { { name: "VIP", company_id: company.id } }

  before { token_login(user, event) }

  describe "GET #index" do
    before { create_list(:ticket_type, 10, event: event) }

    it "returns a success response" do
      get :index, params: { event_id: event.id }
      expect(response).to have_http_status(:ok)
    end

    it "returns all ticket_types" do
      get :index, params: { event_id: event.id }
      expect(json.size).to be(10)
    end

    it "does not return ticket_types from another event" do
      new_ticket_type = create(:ticket_type)
      get :index, params: { event_id: event.id }
      expect(json).not_to include(obj_to_json(new_ticket_type, "TicketTypeSerializer"))
    end
  end

  describe "GET #show" do
    it "returns a success response" do
      get :show, params: { event_id: event.id, id: ticket_type.to_param }
      expect(response).to have_http_status(:ok)
    end

    it "returns the ticket_type as JSON" do
      get :show, params: { event_id: event.id, id: ticket_type.to_param }
      expect(json).to eq(obj_to_json(ticket_type, "TicketTypeSerializer"))
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new TicketType" do
        expect do
          post :create, params: { event_id: event.id, ticket_type: valid_attributes }
        end.to change(TicketType, :count).by(1)
      end

      it "returns a created response" do
        post :create, params: { event_id: event.id, ticket_type: valid_attributes }
        expect(response).to be_created
      end

      it "returns the created ticket_type" do
        post :create, params: { event_id: event.id, ticket_type: valid_attributes }
        expect(json["id"]).to eq(TicketType.last.id)
      end
    end

    context "with invalid params" do
      it "returns an unprocessable_entity response" do
        post :create, params: { event_id: event.id, ticket_type: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      let(:new_attributes) { { name: "General" } }

      before { ticket_type }

      it "updates the requested ticket_type" do
        expect do
          put :update, params: { event_id: event.id, id: ticket_type.to_param, ticket_type: new_attributes }
        end.to change { ticket_type.reload.name }.to("General")
      end

      it "returns the ticket_type" do
        put :update, params: { event_id: event.id, id: ticket_type.to_param, ticket_type: valid_attributes }
        expect(json["id"]).to eq(ticket_type.id)
      end
    end

    context "with invalid params" do
      it "returns an unprocessable_entity response" do
        put :update, params: { event_id: event.id, id: ticket_type.to_param, ticket_type: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "DELETE #destroy" do
    before { ticket_type }

    it "destroys the requested ticket_type" do
      expect do
        delete :destroy, params: { event_id: event.id, id: ticket_type.to_param }
      end.to change(TicketType, :count).by(-1)
    end

    it "returns a success response" do
      delete :destroy, params: { event_id: event.id, id: ticket_type.to_param }
      expect(response).to have_http_status(:ok)
    end
  end
end
