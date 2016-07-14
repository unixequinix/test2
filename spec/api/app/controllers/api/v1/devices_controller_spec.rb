require "rails_helper"

RSpec.describe Api::V1::EventsController, type: :controller do
  let(:admin) { create(:admin) }

  describe "POST create" do
    pending "creates the device if it doesn't exist"
    pending "updates the device asset_tracker"
  end
end
