FactoryGirl.define do
  factory :event do
    name { "Event #{SecureRandom.hex(16)}" }
    state "started"
    start_date { Time.zone.now }
    end_date { Time.zone.now + 2.days }
    support_email "support@glownet.com"
    currency "EUR"
    gtag_type "ultralight_c"

    # Event states

    trait :launched do
      state "launched"
    end

    trait :started do
      state "started"
    end

    trait :finished do
      state "finished"
    end

    trait :closed do
      state "closed"
    end

    after :create do |event|
      event.create_credit(value: 1, name: "CRD")
    end
  end
end
