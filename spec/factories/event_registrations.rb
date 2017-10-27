FactoryBot.define do
  factory :event_registration do
    event
    role { :promoter }
    email { "jake@glownet.com" }
  end
end
