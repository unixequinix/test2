require "rails_helper"

RSpec.describe Api::V1::Events::CompanyTicketTypesController, type: :controller do
  let(:event) { Event.first || build(:event) }
  let(:admin) { Admin.first || create(:admin) }
  let(:db_ticket_types) do
    CompanyTicketType.where(event: event).map(&:id)
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
          expect(api_ticket_types).to eq(db_ticket_types)
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
