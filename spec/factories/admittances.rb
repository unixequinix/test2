# == Schema Information
#
# Table name: admittances
#
#  id           :integer          not null, primary key
#  admission_id :integer
#  ticket_id    :integer
#  deleted_at   :datetime
#  aasm_state   :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

FactoryGirl.define do
  factory :admittance do
    admission
    ticket
    aasm_state 'assigned'
  end
end
