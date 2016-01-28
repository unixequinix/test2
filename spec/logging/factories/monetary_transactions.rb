FactoryGirl.define do
  factory :monetary_transaction do
    event
    transaction_type { Faker::Lorem.word }
    device_created_at { Time.now }
    customer_tag_uid { Faker::Lorem.word }
    operator_tag_uid { Faker::Lorem.word }
    device_uid { Faker::Lorem.word }
    customer_event_profile
    payment_method { Faker::Lorem.word }
    amount { Faker::Number.decimal(2) }
    status_code "0"
    status_message "OK"
  end
end