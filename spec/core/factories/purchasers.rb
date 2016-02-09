FactoryGirl.define do
  factory :purchaser do
    first_name { Faker::Name.first_name }
    last_name {Faker::Name.last_name }
    email { Faker::Internet.email }
    gtag_delivery_address { Faker::Address.street_address + " " +
                            Faker::Address.secondary_address + " " +
                            Faker::Address.postcode + " " +
                            Faker::Address.city
                          }
    trait :gtag_credential do
      association :credentiable, factory: :gtag
    end

    trait :ticket_credential do
      association :credentiable, factory: :ticket
    end

    factory :purchaser_gtag, traits: [:gtag_credential]
    factory :purchaser_ticket, traits: [:ticket_credential]
  end
end
