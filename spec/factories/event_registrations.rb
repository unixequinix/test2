FactoryBot.define do
  factory :event_registration do
    event
    user
    role { :promoter }
  end
end
