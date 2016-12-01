require "spec_helper"

RSpec.describe Api::V1::Events::TicketTypesController, type: :controller do
  let(:event) { create(:event) }
  let(:admin) { create(:admin) }
  let(:db_ticket_types) { event.ticket_types }

  before do
    create(:ticket_type, event: event)
    @new_ticket_type = create(:ticket_type, event: event)
    @new_ticket_type.update!(updated_at: Time.zone.now + 4.hours)
  end

  describe "GET index" do
    context "when authenticated" do
      before { http_login(admin.email, admin.access_token) }

      it "returns a 200 status code" do
        get :index, event_id: event.id
        expect(response).to be_ok
      end

      it "returns the necessary keys" do
        get :index, event_id: event.id
        ticket_type_keys = %w( id name company_id company_name ticket_type_ref catalog_item_id )
        JSON.parse(response.body).map { |ticket_type| expect(ticket_type.keys).to eq(ticket_type_keys) }
      end

      context "with the 'If-Modified-Since' header" do
        it "returns only the modified ticket_types" do
          request.headers["If-Modified-Since"] = (@new_ticket_type.updated_at - 2.hours)
          get :index, event_id: event.id
          ticket_types = JSON.parse(response.body).map { |m| m["id"] }
          expect(ticket_types).to eq([@new_ticket_type.id])
        end
      end

      context "without the 'If-Modified-Since' header" do
        it "returns all the ticket_types" do
          get :index, event_id: event.id
          api_ticket_types = JSON.parse(response.body).map { |m| m["id"] }
          expect(api_ticket_types).to eq(db_ticket_types.map(&:id))
        end
      end
    end

    context "when unauthenticated" do
      it "returns a 401 status code" do
        get :index, event_id: event.id
        expect(response).to be_unauthorized
      end
    end
  end
end
