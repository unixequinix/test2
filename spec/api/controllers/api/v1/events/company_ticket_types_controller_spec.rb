require "rails_helper"

RSpec.describe Api::V1::Events::CompanyTicketTypesController, type: :controller do
  let(:event) { build(:event) }
  let(:admin) { create(:admin) }

  before do
    create_list(:company_ticket_type, 2, event: event)
  end

  describe "GET index" do
    context "with authentication" do
      before(:each) do
        http_login(admin.email, admin.access_token)
      end

      it "has a 200 status code" do
        get :index, event_id: event.id
        expect(response.status).to eq 200
      end

      it "returns all the company ticket types" do
        get :index, event_id: event.id

        body = JSON.parse(response.body)
        ticket_types = body.map { |m| m["name"] }

        expect(ticket_types).to match_array(CompanyTicketType.all.map(&:name))
        expect(body.first.keys.sort).to contain_exactly("company_id", "company_name",
                                                        "company_ticket_type_ref", "id", "name",
                                                        "preevent_product_id")
      end
    end
    context "without authentication" do
      it "has a 401 status code" do
        get :index, event_id: event.id

        expect(response.status).to eq 401
      end
    end
  end
end
