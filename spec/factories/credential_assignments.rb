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

    trait :assigned do
      aasm_state "assigned"
    end

    trait :unassigned do
      aasm_state "unassigned"
    end

    trait :gtag_credential do
      association :credentiable, factory: :gtag
    end

    trait :ticket_credential do
      association :credentiable, factory: :ticket
    end

    factory :credential_assignment_g_a, traits: [:gtag_credential, :assigned]
    factory :credential_assignment_g_u, traits: [:gtag_credential, :assigned]
    factory :credential_assignment_t_a, traits: [:ticket_credential, :unassigned]
    factory :credential_assignment_t_u, traits: [:ticket_credential, :unassigned]
  end
end
