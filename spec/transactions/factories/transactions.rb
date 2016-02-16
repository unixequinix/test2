FactoryGirl.define do
  factory :transaction, class: "Transaction" do
    event
    station
    device
    customer_event_profile
    transaction_type { "word #{rand(100)}" }
    device_created_at { Time.now }
    customer_tag_uid { "word #{rand(100)}" }
    operator_tag_uid { "word #{rand(100)}" }
    device_uid { "word #{rand(100)}" }
    payment_method { %w(bank_account epg).sample }
    status_code "0"
    status_message "OK"
    credits { rand(10) }
    credits_refundable { rand(10) }
    value_credit { rand(10) }
    payment_gateway { [nil, "braintree", "stripe"].sample }
    final_balance { rand(10) }
    final_refundable_balance { rand(10) }
    direction { rand(2) }
    access_entitlement_value { rand(10) }
  end

  factory :monetary_transaction, parent: :transaction, class: "MonetaryTransaction"
  factory :credential_transaction, parent: :transaction, class: "CredentialTransaction"
  factory :access_transaction, parent: :transaction, class: "AccessTransaction"
end
