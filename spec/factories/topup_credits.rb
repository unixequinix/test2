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

FactoryGirl.define do
  factory :topup_credit do
    station
    credit
    sequence(:amount) { |n| n }
  end
end
