require "rails_helper"

RSpec.describe Station, type: :model do
  subject { build(:station) }

  describe ".add_predefined_values" do
    it "adds default buttons when is a topup/refund station" do
      station = build(:station, category: "top_up_refund")
      expect { station.save! }.to change(TopupCredit, :count).by(6)
      expect(station.topup_credits.map(&:amount).sort).to eq([1, 5, 10, 20, 25, 50].sort)
    end

    it "adds default buttons when is a cs topup station" do
      station = build(:station, category: "cs_topup_refund")
      expect { station.save! }.to change(TopupCredit, :count).by(6)
      expect(station.topup_credits.map(&:amount).sort).to eq([0.01, 0.10, 0.50, 1, 5, 10].sort)
    end
  end

  describe ".form" do
    it "returns the association of the given category" do
      s1 = create(:station, category: "vendor")
      s2 = create(:station, category: "box_office")

      expect(s1.form).to eq(:pos)
      expect(s2.form).to eq(:accreditation)
    end
  end

  describe ".group" do
    it "returns the group of the given category" do
      stub_const("Station::GROUPS", foo: [:bar])
      expect(build(:station, category: :bar).group).to eql("foo")
    end

    it "returns empty string if category is not found" do
      expect(build(:station, category: :meh).group).to eql("")
    end

    it "returns nil if category is nil" do
      expect(build(:station, category: nil).group).to eql(nil)
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
end
