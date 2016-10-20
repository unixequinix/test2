require "rails_helper"

RSpec.describe Station, type: :model do
  let(:station) { build(:station) }
  let(:event) { create(:event) }

  it "is expected to be valid" do
    expect(station).to be_valid
  end

  describe ".add_predefined_values" do
    it "adds default buttons when is a topup/refund station" do
      station = build(:station, group: "monetary", category: "top_up_refund", event: event)

      expect { station.save }.to change(TopupCredit, :count).by(6)
      expect(station.topup_credits.map(&:amount).sort).to eq([1, 5, 10, 20, 25, 50].sort)
    end

    it "adds default buttons when is a cs topup station" do
      station = build(:station, group: "monetary", category: "cs_topup_refund", event: event)
      expect { station.save }.to change(TopupCredit, :count).by(6)
      expect(station.topup_credits.map(&:amount).sort).to eq([0.01, 0.10, 0.50, 1, 5, 10].sort)
    end
  end

  describe ".form" do
    it "returns the association of the given category" do
      s1 = create(:station, group: "monetary", category: "vendor", event: event)
      s2 = create(:station, group: "access", category: "box_office", event: event)

      expect(s1.form).to eq(:pos)
      expect(s2.form).to eq(:accreditation)
    end
  end
end
