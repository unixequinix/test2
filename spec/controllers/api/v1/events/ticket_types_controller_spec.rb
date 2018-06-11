require "rails_helper"

RSpec.describe Api::V1::Events::TicketTypesController, type: %i[controller api] do
  let(:event) { create(:event, open_devices_api: true) }
  let(:db_ticket_types) { event.ticket_types }
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
      create(:ticket_type, event: event)
      @new_ticket_type = create(:ticket_type, event: event)
      @new_ticket_type.update!(updated_at: Time.zone.now + 4.hours)
    end

    context "when authenticated" do
      it "returns a 200 status code" do
        get :index, params: params
        expect(response).to be_ok
      end

      it "returns all ticket types" do
        get :index, params: params
        json = JSON.parse(response.body)
        expect(json.size).to be(event.ticket_types.count)
      end

      it "does not return a ticket type from another event" do
        get :index, params: { event_id: create(:event, open_devices_api: true).id, app_version: "5.7.0" }
        ticket_types = JSON.parse(response.body)
        expect(ticket_types).not_to include(obj_to_json_v1(@new_ticket_type, "TicketTypeSerializer"))
      end
      it "returns the necessary keys" do
        get :index, params: params
        ticket_type_keys = %w[id name catalog_item_id catalog_item_type company_id company_name ticket_type_ref]
        JSON.parse(response.body).map { |ticket_type| expect(ticket_type.keys).to eq(ticket_type_keys) }
      end

      context "without the 'If-Modified-Since' header" do
        it "returns all the ticket_types" do
          get :index, params: params
          api_ticket_types = JSON.parse(response.body).map { |m| m["id"] }
          expect(api_ticket_types).to eq(db_ticket_types.map(&:id))
        end

        it "contains a new ticket type" do
          get :index, params: params
          ticket_types = JSON.parse(response.body)
          expect(ticket_types).to include(obj_to_json_v1(@new_ticket_type, "TicketTypeSerializer"))
        end
      end
    end
  end
end
