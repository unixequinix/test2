FactoryGirl.define do
  factory :monetary_transaction do
    transaction_type { "word #{rand(100)}" }
    device_created_at { Time.now }
    customer_tag_uid { SecureRandom.urlsafe_base64.upcase }
    operator_tag_uid { SecureRandom.urlsafe_base64.upcase }
    device_uid { "word #{rand(100)}" }
    status_code "0"
    status_message "OK"
    credits { rand(10) }
    credits_refundable { rand(10) }
    value_credit { rand(10) }
    payment_gateway { [nil, "braintree", "stripe"].sample }
    payment_method { %w(bank_account epg).sample }
    final_balance { rand(10) }
    final_refundable_balance { rand(10) }
  end

  factory :credential_transaction do
    transaction_type { "word #{rand(100)}" }
    device_created_at { Time.now }
    customer_tag_uid { SecureRandom.urlsafe_base64.upcase }
    operator_tag_uid { SecureRandom.urlsafe_base64.upcase }
    device_uid { "word #{rand(100)}" }
    status_code "0"
    status_message "OK"
  end

  factory :access_transaction do
    transaction_type { "word #{rand(100)}" }
    device_created_at { Time.now }
    customer_tag_uid { SecureRandom.urlsafe_base64.upcase }
    operator_tag_uid { SecureRandom.urlsafe_base64.upcase }
    device_uid { "word #{rand(100)}" }
    status_code "0"
    status_message "OK"
    direction { rand(2) }
    access_entitlement_value { rand(10) }
  end
end
