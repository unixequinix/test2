# == Schema Information
#
# Table name: admissions
#
#  id                        :integer          not null, primary key
#  customer_event_profile_id :integer
#  ticket_id                 :integer
#  deleted_at                :datetime
#  aasm_state                :string
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#

FactoryGirl.define do
  factory :admission do
    customer_event_profile
    ticket

    before :create do |admission, evaluator|
      evaluator.customer_event_profile.event = evaluator.ticket.event
    end
  end
end
