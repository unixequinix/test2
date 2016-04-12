require "rails_helper"

RSpec.describe StationType, type: :model do
  let(:station_type) { build(:station_type) }

  it "is expected to be valid" do
    expect(station_type).to be_valid
  end
end
