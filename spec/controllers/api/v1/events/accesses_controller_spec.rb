require "rails_helper"

RSpec.describe Api::V1::Events::AccessesController, type: :controller do
  let(:event) { create(:event) }
  let(:db_accesses) { event.accesses }
  let(:params) { { event_id: event.id, app_version: "5.7.0" } }
  let(:team) { create(:team) }
  let(:user) { create(:user, team: team, role: "glowball") }
  let(:device) { create(:device, team: team) }
  let(:device_token) { "#{device.app_id}+++#{device.serial}+++#{device.mac}+++#{device.imei}" }

  before do
    user.event_registrations.create!(email: "foo@bar.com", user: user, event: event)
    create(:access, event: event)
    @new_access = create(:access, event: event, updated_at: Time.zone.now + 4.hours)

    request.headers["HTTP_DEVICE_TOKEN"] = Base64.encode64(device_token)
    http_login(user.email, user.access_token)
  end

  describe "GET index" do
    context "when authenticated" do
      it "returns a 200 status code" do
        get :index, params: params
        expect(response).to be_ok
      end

      it "returns the necessary keys" do
        get :index, params: params
        access_keys = %w[id name mode memory_length position]
        JSON.parse(response.body).map { |access| expect(access.keys).to eq(access_keys) }
      end

      context "without the 'If-Modified-Since' header" do
        it "returns all the accesses" do
          get :index, params: params
          api_accesses = JSON.parse(response.body).map { |m| m["id"] }
          expect(api_accesses).to eq(db_accesses.map(&:id))
        end
      end
    end
  end
end
