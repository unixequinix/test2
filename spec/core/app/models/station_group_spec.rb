require "rails_helper"

RSpec.describe StationGroup, type: :model do
  let(:station_group) { build(:station_group) }

  it "is expected to be valid" do
    expect(station_group).to be_valid
  end
end
