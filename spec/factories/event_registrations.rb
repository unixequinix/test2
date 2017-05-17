FactoryGirl.define do
  factory :event_registration do
    event
    role { 0 }
    email { "jake@glownet.com" }
  end
end
