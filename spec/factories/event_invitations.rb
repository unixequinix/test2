FactoryBot.define do
  factory :event_invitation do
    event
    role { :support }
    email { "andres@glownet.com" }
  end
end
