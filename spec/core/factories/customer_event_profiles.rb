# == Schema Information
#
# Table name: customer_event_profiles
#
#  id          :integer          not null, primary key
#  customer_id :integer          not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  event_id    :integer          not null
#  deleted_at  :datetime
#

FactoryGirl.define do
  factory :customer_event_profile do
    event
    after(:build) do |customer_event_profile|
      customer_event_profile.customer ||= build(:customer,
                                                customer_event_profile: customer_event_profile)
    end
  end
end
