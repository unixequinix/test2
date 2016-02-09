require "rails_helper"

RSpec.describe Api::V1::Events::BannedTicketsController, :type => :controller do
  describe "GET index" do
    before do
      @event = create :event
      10.times do
        create(:ticket, :banned, event: @event)
      end
    end

    context "with authentication" do
      before(:each) do
        @admin = FactoryGirl.create(:admin)
        http_login(@admin.email, @admin.access_token)
      end

      it "has a 200 status code" do
        get :index, event_id: Event.last.id

        expect(response.status).to eq 200
      end

      it "returns all the banned tickets" do
        get :index, event_id: @event.id

        body = JSON.parse(response.body)
        banned_tickets = body.map { |m| m["reference"] }

        expect(banned_tickets).to match_array(Ticket.banned.map(&:code))
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
