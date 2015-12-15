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

=begin
    factory :credential_assignments do
      customer_event_profile

      transient do
        counter 1
      end
      after(:build) do |ca, evaluator|
        build_list(:credential_assignment_g_a ,evaluator.counter,customer_event_profile_id: ca.customer_event_profile.id, event_id: ca.customer_event_profile.event_id)
      end
    end
    factory :credential_assignments do
      association :credentiable, factory: :gtag
      after
    end

    transient do
      loops 5
      state "unassigned"
    end
      cep = credential_assignment aasm_state: "assigned"
      5.times do
        credential_assignment aasm_state: "assigned"
      end
=end
