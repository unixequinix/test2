require "rails_helper"

RSpec.describe Api::V1::Events::ProductsController, type: :controller do
  let(:event) { create(:event, open_devices_api: true) }
  let(:station) { create(:station, event: event) }
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
    before do
      @new_product = create(:product, station: station, updated_at: Time.zone.now + 4.hours)
      @new_product2 = create(:product, station: station)

      @db_products = [@new_product, @new_product2]
    end

    context "when authenticated" do
      before { http_login(user.email, user.access_token) }

      it "returns a 200 status code" do
        get :index, params: params
        expect(response).to be_ok
      end

      it "returns the necessary keys" do
        get :index, params: params
        product_keys = %w[id name description is_alcohol]
        JSON.parse(response.body).map { |product| expect(product.keys).to eq(product_keys) }
      end

      context "without the 'If-Modified-Since' header" do
        it "returns all the products" do
          get :index, params: params
          api_products = JSON.parse(response.body).map { |m| m["id"] }
          expect(api_products).to eq(@db_products.map(&:id))
        end
      end
    end
  end
end
