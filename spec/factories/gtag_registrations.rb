# == Schema Information
#
# Table name: gtag_registrations
#
#  id          :integer          not null, primary key
#  customer_id :integer          not null
#  gtag_id :integer          not null
#  aasm_state  :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

FactoryGirl.define do
  factory :gtag_registration do
    aasm_state 'assigned'
    gtag
    admission
  end
end
