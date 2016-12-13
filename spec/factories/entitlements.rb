# == Schema Information
#
# Table name: entitlements
#
#  memory_length   :integer          default(1)
#  memory_position :integer          not null
#  mode            :string           default("counter")
#
# Indexes
#
#  index_entitlements_on_access_id  (access_id)
#  index_entitlements_on_event_id   (event_id)
#
# Foreign Keys
#
#  fk_rails_dcf903a298  (event_id => events.id)
#

FactoryGirl.define do
  factory :entitlement do
    mode Entitlement::PERMANENT_STRICT
    event

    trait :counter do
      mode Entitlement::COUNTER
    end

    trait :permanent do
      mode Entitlement::PERMANENT
    end

    trait :permanent_strict do
      mode Entitlement::PERMANENT_STRICT
    end

    trait :with_access do
      after(:build) do |entitlement|
        entitlement.access ||= build(:access)
      end
    end
  end
end
