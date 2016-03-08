FactoryGirl.define do
  factory :company do
    name { "Company name #{rand(100)}" }

    trait :with_company_event_agreement do
      after(:build) do |company|
        company.company_event_agreements << build(:company_event_agreement)
      end
    end

  end
end
