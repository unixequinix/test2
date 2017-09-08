require 'rails_helper'

RSpec.describe Api::V2::Events::DevicesController, type: %i[controller api] do
  let(:event) { create(:event, open_api: true, state: "created") }
  let(:user) { create(:user, role: "admin") }
  let(:device) { create(:device) }

  let(:invalid_attributes) { { mac: nil } }
  let(:valid_attributes) { { mac: "FEAA11EE2244#{rand(1000)}" } }

  before do
    token_login(user, event)
    event.devices << device
  end

  describe "GET #index" do
    before do
      devices = create_list(:device, 10)
      event.devices << devices
    end

    it "returns a success response" do
      get :index, params: { event_id: event.id }
      expect(response).to have_http_status(:ok)
    end

    it "returns all devices" do
      get :index, params: { event_id: event.id }
      expect(json.size).to be(11)
    end

    it "does not return devices from another event" do
      new_device = create(:device)
      get :index, params: { event_id: event.id }
      expect(json).not_to include(obj_to_json(new_device, "DeviceSerializer"))
    end
  end

  describe "GET #show" do
    it "returns a success response" do
      get :show, params: { event_id: event.id, id: device.to_param }
      expect(response).to have_http_status(:ok)
    end

    it "returns the device as JSON" do
      get :show, params: { event_id: event.id, id: device.to_param }
      expect(json).to eq(obj_to_json(device, "DeviceSerializer"))
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      let(:new_attributes) { { mac: "1111111111" } }

      before { device }

      it "updates the requested device" do
        expect do
          put :update, params: { event_id: event.id, id: device.to_param, device: new_attributes }
        end.to change { device.reload.mac }.to("1111111111")
      end

      it "returns the device" do
        put :update, params: { event_id: event.id, id: device.to_param, device: valid_attributes }
        expect(json["id"]).to eq(device.id)
      end
    end

    context "with invalid params" do
      it "returns an unprocessable_entity response" do
        put :update, params: { event_id: event.id, id: device.to_param, device: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "DELETE #destroy" do
    before { device }

    it "destroys the requested device" do
      expect do
        delete :destroy, params: { event_id: event.id, id: device.to_param }
      end.to change(DeviceRegistration, :count).by(-1)
    end

    it "returns a success response" do
      delete :destroy, params: { event_id: event.id, id: device.to_param }
      expect(response).to have_http_status(:ok)
    end
  end
end
