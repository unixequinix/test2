FactoryGirl.define do
  factory :transaction, class: "Transaction" do
    event
    station
    device
    customer_event_profile
    preevent_product
    transaction_type { Faker::Lorem.word }
    device_created_at { Time.now }
    customer_tag_uid { Faker::Lorem.word }
    operator_tag_uid { Faker::Lorem.word }
    device_uid { Faker::Lorem.word }
    payment_method { %w(bank_account epg).sample }
    amount { Faker::Number.decimal(2) }
    status_code "0"
    status_message "OK"
  end

  factory :monetary_transaction, parent: :transaction, class: 'MonetaryTransaction'
  factory :credential_transaction, parent: :transaction, class: 'CredentialTransaction'
  factory :access_transaction, parent: :transaction, class: 'AccessTransaction'
end