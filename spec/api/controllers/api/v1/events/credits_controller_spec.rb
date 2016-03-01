require "rails_helper"

RSpec.describe Api::V1::Events::CreditsController, type: :controller do
  before(:all) do
    @event = create(:event)
    create_list(:preevent_item_credit, 2, event: @event)
  end

  describe "GET index" do
    context "with authentication" do
      before(:each) do
        @admin = FactoryGirl.create(:admin)
        http_login(@admin.email, @admin.access_token)
      end

      it "has a 200 status code" do
        get :index, event_id: @event.id

        expect(response.status).to eq 200
      end

      it "returns all the credits" do
        get :index, event_id: @event.id

        body = JSON.parse(response.body)
        credits = body.map { |m| m["currency"] }

        expect(credits).to match_array(Credit.for_event(@event).map(&:currency))
      end
    end
    context "without authentication" do
      it "has a 401 status code" do
        get :index, event_id: @event.id

        expect(response.status).to eq 401
      end
    end
  end
end
