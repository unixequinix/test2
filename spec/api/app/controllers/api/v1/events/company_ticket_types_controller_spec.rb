require "rails_helper"

RSpec.describe Api::V1::Events::CompanyTicketTypesController, type: :controller do
  let(:event) { create(:event) }
  let(:admin) { create(:admin) }
  let(:db_ticket_types) do
    CompanyTicketType.where(event: event)
  end

  before do
    create_list(:company_ticket_type, 2, event: event)
    @new_ticket_type = create(:company_ticket_type, event: event)
    @new_ticket_type.update!(updated_at: Time.now + 4.hours)
  end

  describe "GET index" do
    context "when authenticated" do
      before(:each) do
        http_login(admin.email, admin.access_token)
      end

      it "returns a 200 status code" do
        get :index, event_id: event.id
        expect(response.status).to eq 200
      end

      it "returns the necessary keys" do
        get :index, event_id: event.id
        keys = %w(id name company_id catalog_item_id company_name company_ticket_type_ref)
        JSON.parse(response.body).map do |access|
          expect(access.keys).to eq(keys)
        end
      end

      it "returns the correct data" do
        get :index, event_id: event.id
        JSON.parse(response.body).each_with_index do |ticket_type, index|
          ticket_types_atts = {
            id: db_ticket_types[index].id,
            name: db_ticket_types[index].name,
            company_id: db_ticket_types[index].company_event_agreement.company.id,
            catalog_item_id: db_ticket_types[index].credential_type.catalog_item_id,
            company_name: db_ticket_types[index].company_event_agreement.company.name,
            company_ticket_type_ref: db_ticket_types[index].company_code
          }
          expect(ticket_types_atts.as_json).to eq(ticket_type)
        end
      end

      context "with the 'If-Modified-Since' header" do
        it "returns only the modified ticket types" do
          request.headers["If-Modified-Since"] = (@new_ticket_type.updated_at - 2.hours)
          get :index, event_id: event.id
          ticket_types = JSON.parse(response.body).map { |m| m["id"] }
          expect(ticket_types).to eq([@new_ticket_type.id])
        end
      end

      context "without the 'If-Modified-Since' header" do
        it "returns all the ticket types" do
          get :index, event_id: event.id
          api_ticket_types = JSON.parse(response.body).map { |m| m["id"] }
          expect(api_ticket_types).to eq(db_ticket_types.map(&:id))
        end
      end
    end

    context "when unauthenticated" do
      it "returns a 401 status code" do
        get :index, event_id: event.id
        expect(response.status).to eq 401
      end
    end
  end
end
