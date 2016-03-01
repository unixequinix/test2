require "rails_helper"

RSpec.describe Api::V1::Events::ParametersController, type: :controller do
  describe "GET index" do
    before do
      @event = create(:event)
      @param1 = create(:event_parameter,
                       event: @event,
                       value: "asd123",
                       parameter: Parameter.find_by(category: "device", name: "min_version_apk"))

      @param2 = create(:event_parameter,
                       event: @event,
                       parameter: Parameter.find_by(category: "gtag", name: "gtag_type"),
                       value: "mifare_classic")
    end

    context "with authentication" do
      before(:each) do
        @admin = FactoryGirl.create(:admin)
        http_login(@admin.email, @admin.access_token)
      end

      it "has a 200 status code" do
        get :index, event_id: @event.id

        expect(response.status).to eq 200
      end

      it "returns all the tickets" do
        get :index, event_id: @event.id

        body = JSON.parse(response.body)
        parameters = body.map { |m| m["value"] }

        expect(parameters).to include(@param1.value)
        expect(parameters).to include(@param2.value)
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
