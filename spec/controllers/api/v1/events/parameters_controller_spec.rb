require "spec_helper"

RSpec.describe Api::V1::Events::ParametersController, type: :controller do
  let(:admin) { create(:admin) }
  let(:params) { { gtag_settings: { gtag_type: "ultralight_c", ultralight_c: { test: "ab" } }, device_settings: {} } }
  let(:event) { create(:event, params) }

  describe "GET index" do
    before do
      http_login(admin.email, admin.access_token)
      get :index, event_id: event.id
      @body = JSON.parse(response.body)
    end

    it "should include all " do
      expect(@body).to eq([{ name: "gtag_type", value: "ultralight_c" },
                           { name: "test", value: "ab" }].as_json)
    end
  end
end
