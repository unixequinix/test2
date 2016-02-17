require "rails_helper"

RSpec.describe Api::V1::EventsController, type: :controller do
  describe "GET index" do
    context "with authentication" do
      before(:each) do
        FactoryGirl.create :event, name: "Sonar Barcelona"
        FactoryGirl.create :event, name: "Comic Con Dubai"

        @admin = FactoryGirl.create(:admin)
        http_login(@admin.email, @admin.access_token)
      end

      it "has a 200 status code" do
        get :index

        expect(response.status).to eq 200
      end

      it "returns all the events" do
        get :index

        body = JSON.parse(response.body)
        event_names = body.map { |m| m["name"] }

        expect(event_names).to match_array(["Sonar Barcelona", "Comic Con Dubai"])
      end
    end
    context "without authentication" do
      it "has a 401 status code" do
        get :index

        expect(response.status).to eq 401
      end
    end
  end
end
