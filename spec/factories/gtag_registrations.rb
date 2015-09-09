# == Schema Information
#
# Table name: gtag_registrations
#
#  id                        :integer          not null, primary key
#  gtag_id                   :integer          not null
#  aasm_state                :string
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  customer_event_profile_id :integer          not null
#

FactoryGirl.define do
  factory :gtag_registration do
    gtag
    customer_event_profile
  end
end
