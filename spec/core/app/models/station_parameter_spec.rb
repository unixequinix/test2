require "rails_helper"

RSpec.describe StationParameter, type: :model do
  let(:station) { build(:station_parameter) }

  it "is expected to be valid" do
    expect(station).to be_valid
  end
end
