# == Schema Information
#
# Table name: preevent_product_units
#
#  id               :integer          not null, primary key
#  purchasable_id   :integer          not null
#  purchasable_type :string           not null
#  event_id         :integer
#  name             :string
#  description      :text
#  initial_amount   :integer
#  price            :decimal(, )
#  step             :integer
#  deleted_at       :datetime
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

FactoryGirl.define do
  factory :preevent_product_unit do
    name { Faker::App.name }
    description { Faker::Lorem.sentence }
    initial_amount { Faker::Number.between(1, 20) }
    price { Faker::Commerce.price }
    step { Faker::Number.between(1, 5) }
    association :purchasable, factory: :credit
    event

    trait :credit_product do
      association :purchasable, factory: :credit
    end

    trait :voucher_product do
      association :purchasable, factory: :voucher
    end

    trait :credential_type_product do
      association :purchasable, factory: :credential_type
    end

    factory :preevent_product_unit_credit, traits: [:credit_product]
    factory :preevent_product_unit_voucher, traits: [:voucher_product]
    factory :preevent_product_unit_credential_type, traits: [:credential_type_product]
  end
end
