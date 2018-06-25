require "rails_helper"

RSpec.describe Api::V1::Events::CreditsController, type: %i[controller api] do
  let(:event) { create(:event, open_devices_api: true) }
  let(:params) { { event_id: event.id, app_version: "5.7.0" } }
  let(:team) { create(:team) }
  let(:user) { create(:user, team: team, role: "glowball") }
  let(:device) { create(:device, team: team) }
  let(:device_token) { "#{device.app_id}+++#{device.serial}+++#{device.mac}+++#{device.imei}" }

  before do
    user.event_registrations.create!(email: "foo@bar.com", user: user, event: event)
    request.headers["HTTP_DEVICE_TOKEN"] = Base64.encode64(device_token)
    http_login(user.email, user.access_token)
  end

  describe "GET index" do
    context "when authenticated" do
      it "returns a 200 status code" do
        get :index, params: params
        expect(response).to be_ok
      end

      it "returns a right response" do
        get :index, params: params
        json = JSON.parse(response.body)
        expect(json).to include(obj_to_json_v1(event.credit, "CreditSerializer"))
      end

      it "returns the necessary keys" do
        get :index, params: params
        credit_keys = %w[id name value currency credit_symbol currency_symbol]
        credit_keys.each { |key| JSON.parse(response.body).map { |credit| expect(credit.keys).to include(key) } }
      end

      it "does not return an credit from another event" do
        get :index, params: { event_id: create(:event), app_version: "5.7.0" }
        json = JSON.parse(response.body)
        expect(json).not_to include(obj_to_json_v1(event.credit, "CreditSerializer"))
      end
    end
  end
end
