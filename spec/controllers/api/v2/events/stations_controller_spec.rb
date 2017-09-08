require 'rails_helper'

RSpec.describe Api::V2::Events::StationsController, type: %i[controller api] do
  let(:event) { create(:event, open_api: true, state: "created") }
  let(:user) { create(:user) }
  let(:station) { create(:station, event: event) }

  let(:invalid_attributes) { { name: nil } }
  let(:valid_attributes) { { name: "bar", category: "bar" } }

  before { token_login(user, event) }

  describe "GET #index" do
    before { create_list(:station, 10, event: event) }

    it "returns a success response" do
      get :index, params: { event_id: event.id }
      expect(response).to have_http_status(:ok)
    end

    it "returns all stations" do
      get :index, params: { event_id: event.id }
      expect(json.size).to be(10)
    end

    it "does not return stations from another event" do
      station.update!(event: create(:event))
      get :index, params: { event_id: event.id }
      expect(json).not_to include(obj_to_json(station, "StationSerializer"))
    end
  end

  describe "GET #show" do
    it "returns a success response" do
      get :show, params: { event_id: event.id, id: station.to_param }
      expect(response).to have_http_status(:ok)
    end

    it "returns the station as JSON" do
      get :show, params: { event_id: event.id, id: station.to_param }
      expect(json).to eq(obj_to_json(station, "StationSerializer"))
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new Station" do
        expect do
          post :create, params: { event_id: event.id, station: valid_attributes }
        end.to change(Station, :count).by(1)
      end

      it "returns a created response" do
        post :create, params: { event_id: event.id, station: valid_attributes }
        expect(response).to be_created
      end

      it "returns the created station" do
        post :create, params: { event_id: event.id, station: valid_attributes }
        expect(json["id"]).to eq(Station.last.id)
      end
    end

    context "with invalid params" do
      it "returns an unprocessable_entity response" do
        post :create, params: { event_id: event.id, station: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      let(:new_attributes) { { name: "new bar" } }

      before { station }

      it "updates the requested station" do
        expect do
          put :update, params: { event_id: event.id, id: station.to_param, station: new_attributes }
        end.to change { station.reload.name }.to("new bar")
      end

      it "returns the station" do
        put :update, params: { event_id: event.id, id: station.to_param, station: valid_attributes }
        expect(json["id"]).to eq(station.id)
      end
    end

    context "with invalid params" do
      it "returns an unprocessable_entity response" do
        put :update, params: { event_id: event.id, id: station.to_param, station: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "DELETE #destroy" do
    before { station }

    it "destroys the requested station" do
      expect do
        delete :destroy, params: { event_id: event.id, id: station.to_param }
      end.to change(Station, :count).by(-1)
    end

    it "returns a success response" do
      delete :destroy, params: { event_id: event.id, id: station.to_param }
      expect(response).to have_http_status(:ok)
    end
  end
end
