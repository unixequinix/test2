require "rails_helper"

RSpec.describe Api::V1::Events::BannedTicketsController, type: :controller do
  let(:admin) { create(:admin) }
  let(:event) { create(:event) }

  describe "GET index" do
    context "with authentication" do
      before(:each) { http_login(admin.email, admin.access_token) }

      it "has a 200 status code" do
        get :index, event_id: event.id
        expect(response.status).to eq 200
      end

      it "returns all the banned tickets" do
        tickets = create_list(:ticket, 2, banned: true, event: event)
        get :index, event_id: event.id
        body = JSON.parse(response.body)
        ws_tickets = body.map { |m| m["reference"] }
        tickets.each { |ticket|  expect(ws_tickets).to include(ticket.code) }
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
