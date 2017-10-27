
require "rails_helper"

RSpec.describe Api::V1::Events::CreditsController, type: :controller do
  let(:event) { create(:event, open_devices_api: true) }
  let(:user) { create(:user) }
  let(:params) { { event_id: event.id, app_version: "5.7.0" } }

  describe "GET index" do
    context "when authenticated" do
      before { http_login(user.email, user.access_token) }

      it "returns a 200 status code" do
        get :index, params: params
        expect(response).to be_ok
      end

      it "returns the necessary keys" do
        get :index, params: params
        credit_keys = %w[id name value currency credit_symbol currency_symbol]
        credit_keys.each { |key| JSON.parse(response.body).map { |credit| expect(credit.keys).to include(key) } }
      end
    end

    context "when unauthenticated" do
      it "returns a 401 status code" do
        get :index, params: params
        expect(response).to be_unauthorized
      end
    end
  end
end
