# == Schema Information
#
# Table name: admissions
#
#  id          :integer          not null, primary key
#  customer_id :integer          not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  event_id    :integer          default(1), not null
#

FactoryGirl.define do
  factory :admission do
    customer
    event
  end
end
