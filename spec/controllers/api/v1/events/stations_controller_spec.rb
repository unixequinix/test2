require "rails_helper"

RSpec.describe Api::V1::Events::StationsController, type: :controller do
  let(:event) { create(:event) }
  let(:admin) { create(:admin) }

  describe "GET index" do
    context "with authentication" do
      before(:each) do
        http_login(admin.email, admin.access_token)
      end

      it "has a 200 status code" do
        get :index, event_id: event.id
        expect(response.status).to eq(200)
      end

      context "when the station is a box office" do
        before do
          @station = create(:station, event: event, group: "access", category: "box_office")
          @station.station_catalog_items
                  .new(price: rand(1.0...20.0).round(2),
                       catalog_item_id: create(:access_catalog_item, event: event).id,
                       station_parameter_attributes: { station_id: @station.id }).save
        end

        it "returns all the box office stations" do
          get :index, event_id: event.id
          stations = JSON.parse(response.body).first["stations"].map { |m| m["id"] }
          expect(stations).to include(@station.id)
        end

        it "returns the catalog items for each box office" do
          get :index, event_id: event.id
          s = JSON.parse(response.body).first["stations"].first
          s_ws_items = s["catalog"].map { |m| m["catalogable_id"] }
          s_db_items = @station.station_catalog_items.map { |m| m.catalog_item.catalogable_id }

          expect(s).to have_key("catalog")
          expect(s_ws_items).to eq(s_db_items)
        end
      end

      context "when the station is a point of sales" do
        before do
          @station = create(:station, category: "vendor", event: event, group: "monetary")
          @station.station_products
                  .new(price: rand(1.0...20.0).round(2),
                       product: create(:product, event: event),
                       station_parameter_attributes: { station_id: @station.id }).save
        end

        it "returns all the pos stations" do
          get :index, event_id: event.id
          stations = JSON.parse(response.body).first["stations"].map { |m| m["id"] }
          expect(stations).to eq([@station.id])
        end

        it "returns the catalog items for each pos" do
          get :index, event_id: event.id
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
        before { @station = create(:station, category: "top_up_refund", event: event, group: "monetary") }

        it "returns all the pos stations" do
          get :index, event_id: event.id
          stations = JSON.parse(response.body).first["stations"].map { |m| m["id"] }
          expect(stations).to eq([@station.id])
        end

        it "returns the credits for each station" do
          get :index, event_id: event.id
          s = JSON.parse(response.body).first["stations"].first
          expect(s).to have_key("top_up_credits")

          s_ws_items = s["top_up_credits"]
          s_db_items = @station.topup_credits.map do |m|
            { "amount" => m.amount, "price" => (m.credit.value * m.amount).to_f.round(2), "hidden" => m.hidden }
          end
          expect(s_ws_items).to eq(s_db_items)
        end
      end

      context "when the station is an access_control" do
        before do
          access = create(:access_catalog_item, event: event).catalogable
          @station = create(:station, category: "access_control", group: "access", event: event)
          @station.access_control_gates
                  .new(direction: "1",
                       access: access,
                       station_parameter_attributes: { station_id: @station.id }).save
          @station.access_control_gates
                  .new(direction: "-1",
                       access: access,
                       station_parameter_attributes: { station_id: @station.id }).save
        end

        it "returns all the access control stations" do
          get :index, event_id: event.id
          stations = JSON.parse(response.body).first["stations"].map { |m| m["id"] }
          expect(stations).to eq([@station.id])
        end

        it "returns the entitlements for each station" do
          get :index, event_id: event.id
          s = JSON.parse(response.body).first["stations"].first
          expect(s).to have_key("entitlements")

          ws_ent = s["entitlements"]
          db_ent =  {
            "in" => @station.access_control_gates
                            .where(direction: "1")
                            .map { |g| { "id" => g.access_id, "hidden" => g.hidden? } },
            "out" => @station.access_control_gates
                             .where(direction: "-1")
                             .map { |g| { "id" => g.access_id, "hidden" => g.hidden? } }
          }

          expect(ws_ent).to eq(db_ent)
        end
      end
    end
    context "without authentication" do
      it "has a 401 status code" do
        get :index, event_id: event.id

        expect(response.status).to eq(401)
      end
    end
  end
end
