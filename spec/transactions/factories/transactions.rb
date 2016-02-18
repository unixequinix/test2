FactoryGirl.define do
  factory :transaction_parameter, class: "Transaction" do
    customer_event_profile
    transaction_type { "word #{rand(100)}" }
    device_created_at { Time.now }
    customer_tag_uid { "word #{rand(100)}" }
    operator_tag_uid { "word #{rand(100)}" }
    device_uid { "word #{rand(100)}" }
    payment_method { %w(bank_account epg).sample }
    status_code "0"
    status_message "OK"
  end

  factory :monetary_transaction, parent: :transaction_parameter, class: "MonetaryTransaction" do
    credits { rand(10) }
    credits_refundable { rand(10) }
    value_credit { rand(10) }
    payment_gateway { [nil, "braintree", "stripe"].sample }
    payment_method { [nil, "card", "cash"].sample }
    final_balance { rand(10) }
    final_refundable_balance { rand(10) }
  end

  factory :credential_transaction, parent: :transaction_parameter, class: "CredentialTransaction" do
    ticket
    preevent_product
  end

  factory :access_transaction, parent: :transaction_parameter, class: "AccessTransaction" do
    direction { rand(2) }
    access_entitlement_value { rand(10) }
    access_entitlement
  end
end
