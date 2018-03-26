require "rails_helper"

RSpec.describe Api::V1::Events::UserFlagsController, type: %i[controller api] do
  let(:event) { create(:event, open_devices_api: true) }
  let(:db_user_flags) { event.user_flags }
  let(:params) { { event_id: event.id, app_version: "5.7.0" } }
  let(:team) { create(:team) }
  let(:user) { create(:user, team: team, role: "glowball") }
  let(:device) { create(:device, team: team) }
  let(:device_token) { "#{device.app_id}+++#{device.serial}+++#{device.mac}+++#{device.imei}" }

  before do
    user.event_registrations.create!(email: "foo@bar.com", user: user, event: event)
    request.headers["HTTP_DEVICE_TOKEN"] = Base64.encode64(device_token)
    http_login(user.email, user.access_token)

    create(:user_flag, event: event)
    @new_user_flag = create(:user_flag, event: event, updated_at: Time.zone.now + 4.hours)
  end

  describe "GET index" do
    context "when authenticated" do
      it "returns a 200 status code" do
        get :index, params: params
        expect(response).to be_ok
      end

      it "returns all user flags" do
        get :index, params: params
        json = JSON.parse(response.body)
        expect(json).to include(obj_to_json_v1(@new_user_flag, "UserFlagSerializer"))
      end

      it "does not return a flag from another event" do
        get :index, params: { event_id: create(:event, open_devices_api: true).id, app_version: "5.7.0" }
        json = JSON.parse(response.body)
        expect(json).not_to include(obj_to_json_v1(@new_user_flag, "UserFlagSerializer"))
      end
      it "returns the necessary keys" do
        get :index, params: params
        user_flag_keys = %w[id name]
        JSON.parse(response.body).map { |user_flag| expect(user_flag.keys).to eq(user_flag_keys) }
      end

      context "without the 'If-Modified-Since' header" do
        it "returns all the user_flags" do
          get :index, params: params
          api_user_flags = JSON.parse(response.body).map { |m| m["id"] }
          expect(api_user_flags).to eq(db_user_flags.map(&:id))
        end

        it "contains a new user flag" do
          get :index, params: params
          user_flags = JSON.parse(response.body)
          expect(user_flags).to include(obj_to_json_v1(@new_user_flag, "UserFlagSerializer"))
        end
      end
    end
  end
end
