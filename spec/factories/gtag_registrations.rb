# == Schema Information
#
# Table name: gtag_registrations
#
#  id           :integer          not null, primary key
#  gtag_id      :integer          not null
#  aasm_state   :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  admission_id :integer          default(1), not null
#

FactoryGirl.define do
  factory :gtag_registration do
    aasm_state 'assigned'
    gtag
    admission
  end
end
