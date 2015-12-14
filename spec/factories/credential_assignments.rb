# == Schema Information
#
# Table name: credential_assignments
#
#  id                        :integer          not null, primary key
#  customer_event_profile_id :integer          not null
#  credentiable_id           :integer          not null
#  credentiable_type         :string           not null
#  aasm_state                :string
#  deleted_at                :datetime
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#

FactoryGirl.define do
  factory :credential_assignment do
    customer_event_profile
    aasm_state { ["assigned", "unassigned"].sample }
    factory :gtag_credential_assignment do
      association :credentiable, factory: :gtag
    end
    factory :ticket_credential_assignment do
      association :credentiable, factory: :ticket
    end
  end
end
