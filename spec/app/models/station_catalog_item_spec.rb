require "rails_helper"

RSpec.describe StationCatalogItem, type: :model do
  let(:station) { build(:station_catalog_item) }

  it "is expected to be valid" do
    expect(station).to be_valid
  end
end
