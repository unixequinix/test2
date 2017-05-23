require "spec_helper"

RSpec.describe Api::V1::Events::StationsController, type: :controller do
  let(:event) { create(:event) }
  let(:user) { create(:user) }
  let(:params) { { event_id: event.id, app_version: "5.7.0" } }

  describe "GET index" do
    context "with authentication" do
      before(:each) do
        http_login(user.email, user.access_token)
      end

      it "has a 200 status code" do
        get :index, params: params
        expect(response).to be_ok
      end

      context "when the station is a box office" do
        before do
          @station = create(:station, event: event, category: "box_office")
          access = create(:access, event: event)
          @station.station_catalog_items.create(price: rand(1.0...20.0).round(2), catalog_item_id: access.id)
        end

        it "returns all the box office stations" do
          get :index, params: params
          stations = JSON.parse(response.body).first["stations"].map { |m| m["id"] }
          expect(stations).to include(@station.station_event_id)
        end

        it "returns the catalog items for each box office" do
          get :index, params: params
          s = JSON.parse(response.body).first["stations"].first
          s_ws_items = s["catalog"].map { |m| m["catalog_item_id"] }
          s_db_items = @station.station_catalog_items.map { |m| m.catalog_item.id }

          expect(s).to have_key("catalog")
          expect(s_ws_items).to eq(s_db_items)
        end
      end

      context "when the station is a point of sales" do
        before do
          @station = create(:station, category: "vendor", event: event)
          item = create(:product, event: event)
          @station.station_products.create(price: rand(1.0...20.0).round(2), product: item, position: 9)
        end

        it "returns all the pos stations" do
          get :index, params: params
          stations = JSON.parse(response.body).first["stations"].map { |m| m["id"] }
          expect(stations).to eq([@station.station_event_id])
        end

        it "returns the catalog items for each pos" do
          get :index, params: params
          s = JSON.parse(response.body).first["stations"].first
          expect(s).to have_key("products")

          s_ws_items = s["products"]
          s_db_items = @station.station_products.map do |m|
            { product_id: m["product_id"], price: m["price"], position: m["position"], hidden: m["hidden"] }.as_json
          end
          expect(s_ws_items).to eq(s_db_items)
        end
      end

      context "when the station is a top_up_refund" do
        before { @station = create(:station, category: "top_up_refund", event: event) }

        it "returns all the pos stations" do
          get :index, params: params
          stations = JSON.parse(response.body).first["stations"].map { |m| m["id"] }
          expect(stations).to eq([@station.station_event_id])
        end

        it "returns the credits for each station" do
          get :index, params: params
          s = JSON.parse(response.body).first["stations"].first
          expect(s).to have_key("top_up_credits")

          s_ws_items = s["top_up_credits"]
          s_db_items = @station.topup_credits.map do |m|
            { "amount" => m.amount, "price" => (m.credit.value * m.amount).round(2), "hidden" => m.hidden }
          end
          expect(s_ws_items).to eq(s_db_items)
        end
      end

      context "when the station is an access_control" do
        before do
          access = create(:access, event: event)
          @station = create(:station, category: "access_control", event: event)
          @station.access_control_gates.create(direction: "1", access: access)
          @station.access_control_gates.create(direction: "-1", access: access)
        end

        it "returns all the access control stations" do
          get :index, params: params
          stations = JSON.parse(response.body).first["stations"].map { |m| m["id"] }
          expect(stations).to eq([@station.station_event_id])
        end

        it "returns the entitlements for each station" do
          get :index, params: params
          s = JSON.parse(response.body).first["stations"].first
          expect(s).to have_key("entitlements")

          ws_ent = s["entitlements"]
          db_ent =  {
            "in" => @station.access_control_gates.in.map { |g| { "id" => g.access_id, "hidden" => g.hidden? } },
            "out" => @station.access_control_gates.out.map { |g| { "id" => g.access_id, "hidden" => g.hidden? } }
          }

          expect(ws_ent).to eq(db_ent)
        end
      end
    end
    context "without authentication" do
      it "has a 401 status code" do
        get :index, params: params

        expect(response).to be_unauthorized
      end
    end
  end
end
