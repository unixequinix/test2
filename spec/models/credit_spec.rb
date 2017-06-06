require "spec_helper"

RSpec.describe Credit, type: :model do
  subject { create(:credit) }

  it "has a valid factory" do
    expect(subject).to be_valid
  end

  describe ".credits" do
    it "returns 1" do
      expect(subject.credits).to eq(1)
    end
  end

  describe ".set_customer_portal_price" do
    let(:event) { subject.event }
    before do
      @station = event.stations.create! name: "Customer Portal", category: "customer_portal"
      @item = @station.station_catalog_items.create! catalog_item: subject, price: 1
    end

    it "sets the price to whatever the value of the credit is after save" do
      subject.update(value: 4.5)
      expect(@item.reload.price).to eq(4.5)
    end
  end
end
