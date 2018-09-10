require "rails_helper"

RSpec.describe Api::V1::EventsController, type: :controller do
  let(:user) { create(:user) }
  let(:user_with_team) { create(:user) }
  let(:device) { create(:device, asset_tracker: "TEST22") }
  let(:team) { create(:team, leader: user_with_team) }
  let(:events) { create_list(:event, 3, open_devices_api: true) }
end
