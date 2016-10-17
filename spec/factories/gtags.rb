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
      after(:create) do |gtag|
        create(:credential_assignment, :assigned, credentiable: gtag, profile: create(:profile, event: gtag.event))
      end
    end

    trait :assigned_with_customer do
      after(:create) do |gtag|
        profile = create(:profile, :with_customer, event: gtag.event)
        create(:credential_assignment, :assigned, credentiable: gtag, profile: profile)
      end
    end
  end
end
