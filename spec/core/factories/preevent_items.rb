# == Schema Information
#
# Table name: preevent_items
#
#  id               :integer          not null, primary key
#  purchasable_id   :integer          not null
#  purchasable_type :string           not null
#  event_id         :integer
#  name             :string
#  description      :text
#  deleted_at       :datetime
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

FactoryGirl.define do
  factory :preevent_item do
    event_id 1
    name { Faker::Lorem.word }
    description { Faker::Lorem.sentence }

    trait :credit_item do
      after(:build) do |preevent_item|
        preevent_item.purchasable ||= build(:credit, preevent_item: preevent_item)
      end
    end

    trait :standard_credit_item do
      after(:build) do |preevent_item|
        preevent_item.purchasable ||= build(:standard_credit, preevent_item: preevent_item)
      end
    end

    trait :credential_item do
      after(:build) do |preevent_item|
        preevent_item.purchasable ||= build(:credential_type, preevent_item: preevent_item)
      end
    end

    trait :voucher_item do
      after(:build) do |preevent_item|
        preevent_item.purchasable ||= build(:voucher, preevent_item: preevent_item)
      end
    end

    factory :preevent_item_credit, traits: [:credit_item]
    factory :preevent_item_standard_credit, traits: [:standard_credit_item]
    factory :preevent_item_credential, traits: [:credential_item]
    factory :preevent_item_voucher, traits: [:voucher_item]
  end
end
