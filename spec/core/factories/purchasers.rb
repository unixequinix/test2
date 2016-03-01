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
    first_name { "Name #{rand(100)}" }
    last_name { "Some name #{rand(100)}" }
    email { "someemail@somedomain#{rand(100)}.com" }

    trait :with_gtag_delivery_address do
      gtag_delivery_address do
        "#{rand(100)} some street, #{rand(1000)}, country"
      end
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
