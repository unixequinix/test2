require "rails_helper"

RSpec.describe Api::V1::Events::TicketTypesController, type: :controller do
  let(:event) { create(:event, open_devices_api: true) }
  let(:user) { create(:user) }
  let(:db_ticket_types) { event.ticket_types }
  let(:params) { { event_id: event.id, app_version: "5.7.0" } }

  before do
    create(:ticket_type, event: event)
    @new_ticket_type = create(:ticket_type, event: event)
    @new_ticket_type.update!(updated_at: Time.zone.now + 4.hours)
  end

  describe "GET index" do
    context "when authenticated" do
      before { http_login(user.email, user.access_token) }

      it "returns a 200 status code" do
        get :index, params: params
        expect(response).to be_ok
      end

      it "returns the necessary keys" do
        get :index, params: params
        ticket_type_keys = %w[id name ticket_type_ref catalog_item_id catalog_item_type company_name]
        JSON.parse(response.body).map { |ticket_type| expect(ticket_type.keys).to eq(ticket_type_keys) }
      end

      context "without the 'If-Modified-Since' header" do
        it "returns all the ticket_types" do
          get :index, params: params
          api_ticket_types = JSON.parse(response.body).map { |m| m["id"] }
          expect(api_ticket_types).to eq(db_ticket_types.map(&:id))
        end
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
