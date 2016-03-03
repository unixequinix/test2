require "spec_helper"

RSpec.describe Api::V1::Events::BannedTicketsController, type: :controller do
  describe "GET index" do
    let(:event) { build(:event) }
    let(:admin) { Admin.first || create(:admin) }

    before do
      @tickets = create_list(:ticket, 2, :banned, event: event)
    end

    context "with authentication" do
      before(:each) do
        http_login(admin.email, admin.access_token)
      end

      it "has a 200 status code" do
        get :index, event_id: Event.last.id

        expect(response.status).to eq 200
      end

      it "returns all the banned tickets" do
        get :index, event_id: event.id

        body = JSON.parse(response.body)
        banned_tickets = body.map { |m| m["reference"] }

        @tickets.each { |ticket|  expect(banned_tickets).to include(ticket.code) }
      end
    end
    context "without authentication" do
      it "has a 401 status code" do
        get :index, event_id: Event.last.id

        expect(response.status).to eq 401
      end
    end
  end
end
