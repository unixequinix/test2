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
    status_code "0"
    status_message "OK"
    credits { Faker::Number.number(10) }
    credits_refundable { Faker::Number.number(10) }
    value_credit { Faker::Number.number(10) }
    payment_gateway { [nil, "braintree", "stripe"].sample }
    final_balance { Faker::Number.number(10) }
    final_refundable_balance { Faker::Number.number(10) }
    access_entitlement
    direction { Faker::Number.number(2) }
    access_entitlement_value { Faker::Number.number(10) }
  end

  factory :monetary_transaction, parent: :transaction, class: "MonetaryTransaction"
  factory :credential_transaction, parent: :transaction, class: "CredentialTransaction"
  factory :access_transaction, parent: :transaction, class: "AccessTransaction"
end
