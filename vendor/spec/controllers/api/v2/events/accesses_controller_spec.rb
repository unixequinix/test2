require 'rails_helper'

RSpec.describe Api::V2::Events::AccessesController, type: %i[controller api] do
  let(:event) { create(:event, open_api: true, state: "created") }
  let(:user) { create(:user) }
  let(:access) { create(:access, event: event) }

  let(:invalid_attributes) { { name: nil, mode: "test" } }
  let(:valid_attributes) { { name: "test access", mode: "permanent" } }

  before { token_login(user, event) }

  describe "GET #index" do
    before { create_list(:access, 10, event: event) }

    it "returns a success response" do
      get :index, params: { event_id: event.id }
      expect(response).to have_http_status(:ok)
    end

    it "returns all accesses" do
      get :index, params: { event_id: event.id }
      expect(json.size).to be(10)
    end

    it "does not return accesses from another event" do
      access.update!(event: create(:event))
      get :index, params: { event_id: event.id }
      expect(json).not_to include(obj_to_json_v2(access, "AccessSerializer"))
    end
  end

  describe "GET #show" do
    it "returns a success response" do
      get :show, params: { event_id: event.id, id: access.to_param }
      expect(response).to have_http_status(:ok)
    end

    it "returns the access as JSON" do
      get :show, params: { event_id: event.id, id: access.to_param }
      expect(json).to eq(obj_to_json_v2(access, "AccessSerializer"))
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new Access" do
        expect do
          post :create, params: { event_id: event.id, access: valid_attributes }
        end.to change(Access, :count).by(1)
      end

      it "returns a created response" do
        post :create, params: { event_id: event.id, access: valid_attributes }
        expect(response).to be_created
      end

      it "returns the created access" do
        post :create, params: { event_id: event.id, access: valid_attributes }
        expect(json["id"]).to eq(Access.last.id)
      end
    end

    context "with invalid params" do
      it "returns an unprocessable_entity response" do
        post :create, params: { event_id: event.id, access: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      let(:new_attributes) { { name: "new name" } }

      before { access }

      it "updates the requested access" do
        expect do
          put :update, params: { event_id: event.id, id: access.to_param, access: new_attributes }
        end.to change { access.reload.name }.to("new name")
      end

      it "returns the access" do
        put :update, params: { event_id: event.id, id: access.to_param, access: valid_attributes }
        expect(json["id"]).to eq(access.id)
      end
    end

    context "with invalid params" do
      it "returns an unprocessable_entity response" do
        put :update, params: { event_id: event.id, id: access.to_param, access: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "DELETE #destroy" do
    before { access }

    it "destroys the requested access" do
      expect do
        delete :destroy, params: { event_id: event.id, id: access.to_param }
      end.to change(Access, :count).by(-1)
    end

    it "returns a success response" do
      delete :destroy, params: { event_id: event.id, id: access.to_param }
      expect(response).to have_http_status(:ok)
    end
  end
end
