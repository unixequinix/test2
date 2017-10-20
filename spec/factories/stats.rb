FactoryGirl.define do
  factory :stat do
    sequence(:operation_id)
    origin "onsite"
    date { Time.zone.now }
    action { "topup" }
    event
    event_name "some event"
  end
end
