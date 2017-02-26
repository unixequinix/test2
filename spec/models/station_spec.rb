require "spec_helper"

RSpec.describe Station, type: :model do
  subject { build(:station) }

  it "has a valid factory" do
    expect(subject).to be_valid
  end

  describe ".add_predefined_values" do
    it "adds default buttons when is a topup/refund station" do
      station = build(:station, group: "monetary", category: "top_up_refund")
      expect { station.save! }.to change(TopupCredit, :count).by(6)
      expect(station.topup_credits.map(&:amount).sort).to eq([1, 5, 10, 20, 25, 50].sort)
    end

    it "adds default buttons when is a cs topup station" do
      station = build(:station, group: "monetary", category: "cs_topup_refund")
      expect { station.save! }.to change(TopupCredit, :count).by(6)
      expect(station.topup_credits.map(&:amount).sort).to eq([0.01, 0.10, 0.50, 1, 5, 10].sort)
    end
  end

  describe ".form" do
    it "returns the association of the given category" do
      s1 = create(:station, group: "monetary", category: "vendor")
      s2 = create(:station, group: "access", category: "box_office")

      expect(s1.form).to eq(:pos)
      expect(s2.form).to eq(:accreditation)
    end
  end

  describe ".add_station_event_id" do
    it "applies the correct id" do
      subject.save
      expect(subject.station_event_id).to eq(1)
      station2 = create(:station, event_id: subject.event_id)
      expect(station2.station_event_id).to eq(2)
    end
  end

  describe ".unassigned_catalog_items" do
    it "returns the catalog items which aren't current in the station" do
      access = create(:access, event_id: subject.event_id)
      expect(subject.unassigned_catalog_items).to include(access)
    end
  end

  describe ".unassigned_products" do
    it "returns the products which aren't current in the station" do
      product = create(:product, event_id: subject.event_id)
      expect(subject.unassigned_products).to include(product)
    end
  end
end
