require "rails_helper"

RSpec.describe TopupCredit, type: :model do
  subject { build(:topup_credit) }
  let(:station) { subject.station }

  describe "station touch" do
    before(:each) { subject.save }

    it "resets the station updated_at field" do
      expect { subject.update!(amount: 5.5) }.to change(subject.station, :updated_at)
    end
  end

  describe ".valid_topup_credit?" do
    it "adds an error if the station has more than 6 topup_credits" do
      station.topup_credits << create_list(:topup_credit, 7, station: station, credit: subject.credit)
      expect(subject).not_to be_valid
    end
  end
end
