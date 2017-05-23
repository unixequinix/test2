require "spec_helper"

RSpec.describe Api::V1::EventsController, type: :controller do
  let(:user) { create(:user) }
  let(:device) { create(:device) }
  let(:db_events) { Event.all }

  describe "GET index" do
    context "with authentication" do
      before do
        create_list(:event, 2)
        http_login(user.email, user.access_token)
      end

      it "returns a 202 status code if the device doesn't have a asset_tracker_id" do
        get :index, params: { mac: device.mac }
        expect(response.status).to eq(202)
      end

      it "returns a 200 status code if the device has asset_tracker_id" do
        device.update!(asset_tracker: "H20")
        get :index, params: { mac: device.mac }
        expect(response).to be_ok
      end

      it "returns all the events" do
        get :index, params: { mac: device.mac }
        @body = JSON.parse(response.body)
        event_names = @body.map { |m| m["id"] }
        expect(event_names).to eq(db_events.map(&:id))
      end

      it "returns the necessary keys" do
        get :index, params: { mac: device.mac }
        @body = JSON.parse(response.body)
        @body.map do |event|
          expect(event.keys).to eq(%w[id name start_date end_date staging_start staging_end])
        end
      end

      it "returns the correct data" do
        get :index, params: { mac: device.mac }
        @body = JSON.parse(response.body)
        @body.each_with_index do |event, i|
          body_event = db_events[i]
          body_event_atts = {
            id: body_event.id,
            name: body_event.name,
            start_date: Time.use_zone(body_event.timezone) { body_event.start_date },
            end_date: Time.use_zone(body_event.timezone) { body_event.end_date },
            staging_start: body_event.start_date - 7.days,
            staging_end: body_event.end_date + 7.days
          }
          expect(body_event_atts.as_json).to eq(event)
        end
      end
    end
    context "without authentication" do
      it "has a 401 status code" do
        get :index
        expect(response).to be_unauthorized
      end
    end
  end
end
