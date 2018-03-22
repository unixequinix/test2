require "rails_helper"

RSpec.describe Api::V1::Events::PacksController, type: %i[controller api] do
  let(:event) { create(:event, open_devices_api: true) }
  let(:db_packs) { event.packs }
  let(:params) { { event_id: event.id, app_version: "5.7.0" } }
  let(:team) { create(:team) }
  let(:user) { create(:user, team: team, role: "glowball") }
  let(:device) { create(:device, team: team) }
  let(:device_token) { "#{device.app_id}+++#{device.serial}+++#{device.mac}+++#{device.imei}" }

  before do
    user.event_registrations.create!(email: "foo@bar.com", user: user, event: event)
    request.headers["HTTP_DEVICE_TOKEN"] = Base64.encode64(device_token)
    http_login(user.email, user.access_token)
    @pack = create(:full_pack, event: event)
    @new_pack = create(:full_pack, event: event, updated_at: Time.zone.now + 4.hours)
    @pack.pack_catalog_items.find_by(catalog_item_id: event.credit.id).update(amount: 99)
    @pack.pack_catalog_items.find_by(catalog_item_id: event.virtual_credit.id).update(amount: 55)
  end

  describe "GET index" do
    context "when authenticated" do
      before do
        get :index, params: params
      end

      it "returns a 200 status code" do
        expect(response).to be_ok
      end

      it "returns the necessary keys" do
        get :index, params: params
        pack_keys = %w[id name items]
        pack_keys.each { |key| JSON.parse(response.body).map { |pack| expect(pack.keys).to include(key) } }
      end

      context "without the 'If-Modified-Since' header" do
        it "returns all the packs" do
          get :index, params: params
          api_packs = JSON.parse(response.body).map { |m| m["id"] }
          expect(api_packs).to eq(db_packs.map(&:id))
        end

        it "contains a new pack" do
          expect(json).to include(obj_to_json_v1(@new_pack, "PackSerializer"))
        end

        it "contains a pack with credits" do
          expect(json.find { |k| k['id'] == @pack.id }["items"].find { |h| h['id'] == event.credit.id }['amount']).to be(99)
        end

        it "contains a pack with virtual credits" do
          expect(json.find { |k| k['id'] == @pack.id }["items"].find { |h| h['id'] == event.virtual_credit.id }['amount']).to be(55)
        end
      end
    end
  end
end
