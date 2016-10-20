FactoryGirl.define do
  factory :gtag do
    event
    tag_uid { "ERTYUJHB#{rand(100)}GH#{rand(100)}" }

    trait :with_purchaser do
      after(:build) do |gtag|
        create :purchaser, :with_gtag_delivery_address, credentiable: gtag
      end
    end

    trait :assigned do
      profile { create(:profile, event: event) }
    end

    trait :assigned_with_customer do
      profile { create(:profile, :with_customer, event: event) }
    end
  end
end
