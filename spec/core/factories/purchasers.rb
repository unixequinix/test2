# == Schema Information
#
# Table name: purchasers
#
#  id                    :integer          not null, primary key
#  credentiable_id       :integer          not null
#  credentiable_type     :string           not null
#  first_name            :string           not null
#  last_name             :string           not null
#  email                 :string           not null
#  gtag_delivery_address :string
#  deleted_at            :datetime
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#

FactoryGirl.define do
  factory :purchaser do
    first_name { Faker::Name.first_name }
    last_name {Faker::Name.last_name }
    email { Faker::Internet.email }

    trait :with_gtag_delivery_address do
      gtag_delivery_address { Faker::Address.street_address + " " +
                              Faker::Address.secondary_address + " " +
                              Faker::Address.postcode + " " +
                              Faker::Address.city
                            }
    end
    trait :gtag_credential do
      association :credentiable, factory: :gtag
    end

    trait :ticket_credential do
      association :credentiable, factory: :ticket
    end

    factory :purchaser_gtag, traits: [:gtag_credential, :with_gtag_delivery_address]
    factory :purchaser_ticket, traits: [:ticket_credential]
  end
end
