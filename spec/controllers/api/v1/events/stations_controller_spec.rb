require "rails_helper"

RSpec.describe Api::V1::Events::StationsController, type: %i[controller api] do
  let(:event) { create(:event, open_devices_api: true) }
  let(:params) { { event_id: event.id, app_version: "5.7.0" } }
  let(:ticket_type) { create(:ticket_type, event: event) }
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
    context "with authentication" do
      it "has a 200 status code" do
        get :index, params: params
        expect(response).to be_ok
      end

      it "returns all stations" do
        @station = create(:station, event: event)

        get :index, params: params
        json = JSON.parse(response.body)
        expect(json.size).to be(event.stations.count)
      end

      it "does not return a station from another event" do
        @station = create(:station, event: event)

        get :index, params: { event_id: create(:event).id, app_version: "5.7.0" }
        json = JSON.parse(response.body)
        expect(json).not_to include(obj_to_json_v1(@station, "StationSerializer"))
      end

      it "should return common parameters" do
        @station = create(:station, event: event)

        get :index, params: params
        station_keys = JSON.parse(response.body).first["stations"].first.keys
        expect(station_keys).to include("id", "hidden", "display_stats", "station_event_id", "type", "name")
      end

      context "when the station is a box office" do
        before do
          @station = create(:station, event: event, category: "box_office")
          access = create(:access, event: event)
          @station.station_catalog_items.create(price: rand(1.0...20.0).round(2), catalog_item_id: access.id)
        end

        it "returns all the box office station ids" do
          get :index, params: params
          stations = JSON.parse(response.body).first["stations"].map { |m| m["id"] }
          expect(stations).to include(@station.id)
        end

        it "returns all the box office station station_event_ids" do
          get :index, params: params
          stations = JSON.parse(response.body).first["stations"].map { |m| m["station_event_id"] }
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
          create(:product, station: @station, price: rand(1.0...20.0).round(2), position: 9)
        end

        it "returns all the pos stations" do
          get :index, params: params
          stations = JSON.parse(response.body).first["stations"].map { |m| m["id"] }
          expect(stations).to eq([@station.id])
        end

        it "returns the catalog items for each pos" do
          get :index, params: params
          s = JSON.parse(response.body).first["stations"].first
          expect(s).to have_key("products")

          s_ws_items = s["products"]
          s_db_items = @station.products.map { |p| { product_id: p.id, price: p.price, position: p.position, hidden: p.hidden }.as_json }

          expect(s_ws_items).to eq(s_db_items)
        end
      end

      context "when the station is a top_up_refund" do
        before { @station = create(:station, category: "top_up_refund", event: event) }

        it "returns all the pos stations" do
          get :index, params: params
          stations = JSON.parse(response.body).first["stations"].map { |m| m["id"] }
          expect(stations).to eq([@station.id])
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
        it "does not return ticket types of the station" do
          get :index, params: params
          ticket_types_ids = JSON.parse(response.body).first["stations"].map { |m| m["ticket_types_ids"] }
          expect(ticket_types_ids).to eq([nil])
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
          expect(stations).to eq([@station.id])
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

      context "when the station is a check_in" do
        before do
          @station = create(:station, category: "check_in", event: event)
          @ticket_type = create(:ticket_type, event: event)
          @station.ticket_types << @ticket_type
        end

        it "returns all the check_in stations" do
          get :index, params: params
          stations = JSON.parse(response.body).first["stations"].map { |m| m["id"] }
          expect(stations).to eq([@station.id])
        end

        it "returns ticket_types of the station" do
          get :index, params: params
          ticket_types_ids = JSON.parse(response.body).first["stations"].map { |m| m["ticket_types_ids"] }
          expect(ticket_types_ids).to eq([[@ticket_type.id]])
        end
      end

      context "when the station is a ticket_validation" do
        before do
          @station = create(:station, category: "ticket_validation", event: event)
        end

        it "returns ticket types of the station" do
          @station.ticket_types << ticket_type
          get :index, params: params
          ticket_types_ids = JSON.parse(response.body).first["stations"].map { |m| m["ticket_types_ids"] }
          expect(ticket_types_ids).to eq([[ticket_type.id]])
        end
        it "returns 0 ticket types of the station" do
          get :index, params: params
          ticket_types_ids = JSON.parse(response.body).first["stations"].map { |m| m["ticket_types_ids"] }
          expect(ticket_types_ids).to eq([[]])
        end
      end
    end
  end
end
