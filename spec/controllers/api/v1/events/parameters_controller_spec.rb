require "spec_helper"

RSpec.describe Api::V1::Events::ParametersController, type: :controller do
  let(:admin) { create(:admin) }
  let(:params) { { gtag_settings: { mifare: {}, gtag_type: :mifare }, device_settings: {} } }
  let(:event) { create(:event, params) }

  describe "GET index" do
    before do
      http_login(admin.email, admin.access_token)
      get :index, event_id: event.id
      @body = JSON.parse(response.body)
    end

    it "should include all " do
      expect(@body).to eq("mifare" => {}, "gtag_type" => "mifare")
    end
  end
end
