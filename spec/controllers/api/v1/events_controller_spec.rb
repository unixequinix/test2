require "rails_helper"

RSpec.describe Api::V1::EventsController, type: :controller do
  let(:user) { create(:user) }
  let(:device) { create(:device) }
  let(:team) { create(:team) }
  let(:events) { create_list(:event, 3, open_devices_api: true) }

  describe "GET index" do
    context "with authentication" do
      before do
        http_login(user.email, user.access_token)
      end

      context "device does not belong to a team" do
        it "returns unauthorized error" do
          get :index, params: { mac: device.mac }
          expect(response).to be_unauthorized
        end
      end

      context "device belongs to a team" do
        it "returns unauthorized error if has not any associated event" do
          team.devices << device
          get :index, params: { mac: device.mac }
          expect(response).to be_unauthorized
        end

        it "returns unauthorized error if has not any event device registered" do
          team.devices << device
          events[0].team = team
          events[0].save!
          get :index, params: { mac: device.mac }
          expect(response).to be_unauthorized
        end

        it "returns unauthorized error if has not any active associated event" do
          team.devices << device
          events[0].team = team
          events[0].save!
          create(:device_registration, event: events[0], device: device, allowed: true)
          get :index, params: { mac: device.mac }
          expect(response).to be_unauthorized
        end

        context "returns events list" do
          before do
            team.devices << device
            events[0].team = team
            events[0].save!
            create(:device_registration, event: events[0], device: device, allowed: false)
          end

          it "returns active associated events" do
            get :index, params: { mac: device.mac }
            @body = JSON.parse(response.body)
            expect(@body).not_to be_empty
            expect(@body.map { |m| m["name"] }).to eq([events[0].name])
          end

          it "returns the necessary keys" do
            get :index, params: { mac: device.mac }
            @body = JSON.parse(response.body)
            @body.map do |event|
              expect(event.keys).to eq(%w[id name initialization_type start_date end_date staging_start staging_end])
            end
          end

          it "returns the correct data" do
            create(:device_registration, event: events[1], device: device, allowed: false, action: 'LITE_INITIALIZATION')
            get :index, params: { mac: device.mac }
            @body = JSON.parse(response.body)
            @body.each_with_index do |event, i|
              body_event = events[i]
              body_event_atts = {
                id: body_event.id,
                name: body_event.name,
                initialization_type: i == 1 ? 'LITE_INITIALIZATION' : nil,
                start_date: Time.use_zone(body_event.timezone) { body_event.start_date },
                end_date: Time.use_zone(body_event.timezone) { body_event.end_date },
                staging_start: body_event.start_date - 7.days,
                staging_end: body_event.end_date + 7.days
              }
              expect(body_event_atts.as_json).to eq(event)
            end
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
end
