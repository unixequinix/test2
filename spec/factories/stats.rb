FactoryGirl.define do
  factory :stat do
    event
    station
    sequence(:transaction_id)
    transaction_counter 1
    event_name { event.name }
    credit_name { event.credit.name }
    credit_value { event.credit.value }
    action "sale"
    station_name { station.name }
    station_category { station.category }
    date { Time.current.to_s }
    total 10
    payment_method "credits"
    source "device"
  end
end
