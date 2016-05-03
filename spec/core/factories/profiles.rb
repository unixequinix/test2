# == Schema Information
#
# Table name: profiles
#
#  id          :integer          not null, primary key
#  customer_id :integer          not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  event_id    :integer          not null
#  deleted_at  :datetime
#

FactoryGirl.define do
  factory :profile do
    event
    after(:build) do |profile|
      profile.customer ||= build(:customer,
                                 profile: profile)
    end
  end
end
