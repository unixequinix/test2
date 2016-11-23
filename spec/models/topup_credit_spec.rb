# == Schema Information
#
# Table name: topup_credits
#
#  amount     :float
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_topup_credits_on_credit_id   (credit_id)
#  index_topup_credits_on_station_id  (station_id)
#
# Foreign Keys
#
#  fk_rails_c5b24eb933  (station_id => stations.id)
#

require "spec_helper"

RSpec.describe TopupCredit, type: :model do
  subject { build(:topup_credit) }

  describe ".after_update" do
    before(:each) { subject.save }

    it "resets the station updated_at field" do
      expect { subject.update!(amount: 5.5) }.to change(subject.station, :updated_at)
    end
  end
end
