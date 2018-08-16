require "rails_helper"

RSpec.describe Api::V1::DeviceController, type: :controller do
  let(:team) { create(:team) }
  let(:user) { create(:user, team: team, password: "password123", password_confirmation: "password123") }
  let(:device) { create(:device, team: team) }
  let(:device_token) { "#{device.app_id}+++#{device.serial}+++#{device.mac}+++#{device.imei}" }

  before do
    request.headers["HTTP_DEVICE_TOKEN"] = Base64.encode64(device_token)
    http_login(user.email, user.access_token)
  end

  describe "GET show" do
    let(:event) { create(:event) }

    before do
      user.event_registrations.create!(user: user, event: event)
      get :show, params: { device_token: device_token }
      @obj = JSON.parse(response.body).to_h.symbolize_keys
    end

    it "returns a 200 status code" do
      expect(response).to be_ok
    end

    %i[id asset_tracker imei mac serial manufacturer device_model android_version].each do |att|
      it "returns device #{att}" do
        expect(@obj[att]).to eq(device.method(att).call)
      end
    end

    it "returns an event list with a serialized event" do
      serialized_obj = JSON.parse(Api::V1::EventSerializer.new(event, serializer_params: { device: device }).to_json).to_h
      expect(@obj[:events]).not_to be_empty
      expect(@obj[:events].first).to eql(serialized_obj)
    end
  end

  describe "POST create" do
    let(:device_token) { "NEWAPPID+++#{device.serial}+++#{device.mac}+++#{device.imei}" }
    let(:device_params) { { asset_tracker: "E43", imei: "123", mac: "0200", serial: "9876", android_version: "4.3.2" } }
    let(:params) { { device_token: device_token, username: Base64.encode64(user.username), password: Base64.encode64("password123"), device: device_params } }

    it "returns a 401 if user does not exist" do
      post :create, params: params.merge(username: Base64.encode64("bad"))
      expect(response).to have_http_status(:unauthorized)
      expect(JSON.parse(response.body)["error"]).to eql("Incorrect username or password")
    end

    it "returns a 404 if user has no team" do
      user.update! team: nil
      post :create, params: params
      expect(response).to have_http_status(:not_found)
      expect(JSON.parse(response.body)["error"]).to eql("User does not belong to a team")
    end

    context "if asset_tracker is found in the team" do
      before { device.update! asset_tracker: device_params[:asset_tracker] }

      context "when force is false" do
        before { @params = params.merge(force: false) }

        it "returns a 409 conflict" do
          post :create, params: @params
          expect(response).to have_http_status(:conflict)
        end

        it "does not create a new device" do
          expect { post :create, params: @params }.not_to change(Device, :count)
        end
      end

      context "when force is true" do
        before { @params = params.merge(force: true) }

        it "adds (replaced) to old device with same asset tracker" do
          expect { post :create, params: @params }.to change { device.reload.asset_tracker }.to("E43 (replaced by #{user.username})")
        end

        it "creates a new device" do
          expect { post :create, params: @params }.to change(Device, :count).by(1)
        end

        it "returns a 201 created" do
          post :create, params: @params
          expect(response).to have_http_status(:created)
        end

        it "new device created has correct info" do
          post :create, params: @params
          obj = JSON.parse(response.body).to_h.symbolize_keys
          device_params.each { |att, value| expect(obj[att]).to eq(value) }
          expect(obj[:asset_tracker]).to eq("E43")
        end
      end
    end

    context "if asset_tracker is not found in the team" do
      it "returns a 201 created" do
        post :create, params: params
        expect(response).to have_http_status(:created)
      end

      it "returns a device JSON object" do
        post :create, params: params
        obj = JSON.parse(response.body).to_h.symbolize_keys
        device_params.each { |att, value| expect(obj[att]).to eq(value) }
      end

      it "creates a new device" do
        expect { post :create, params: params }.to change(Device, :count).by(1)
      end

      it "does not update the devices app_id" do
        expect { post :create, params: params }.not_to change { device.reload.app_id }.from(device.app_id)
      end

      it "new device created has correct info" do
        post :create, params: params
        obj = JSON.parse(response.body).to_h.symbolize_keys
        device_params.each { |att, value| expect(obj[att]).to eq(value) }
      end
    end
  end
end
