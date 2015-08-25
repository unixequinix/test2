# == Schema Information
#
# Table name: entitlements
#
#  id         :integer          not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  deleted_at :datetime
#  event_id   :integer          not null
#

FactoryGirl.define do
  factory :entitlement do
    name { Faker::Lorem.word }
  end
end
