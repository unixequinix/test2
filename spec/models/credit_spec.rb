require "spec_helper"

RSpec.describe Credit, type: :model do
  subject { build(:credit) }

  it "has a valid factory" do
    expect(subject).to be_valid
  end

  describe ".credits" do
    it "returns 1" do
      expect(subject.credits).to eq(1)
    end
  end

  describe ".set_customer_portal_price" do
    let(:event) { create(:event) }

    it "sets the price to whatever the value of the credit is after save" do
      event.initial_setup!
      credit = event.credit
      credit.update(value: 4.5)
      expect(event.portal_station.station_catalog_items.find_by(catalog_item: credit).price).to eq(4.5)
    end
  end
end
