FactoryGirl.define do
  factory :money_transaction do
    transaction_type { "word #{rand(100)}" }
    device_created_at { Time.zone.now }
    customer_tag_uid { SecureRandom.urlsafe_base64.upcase }
    operator_tag_uid { SecureRandom.urlsafe_base64.upcase }
    device_uid { "word #{rand(100)}" }
    status_code "0"
    status_message "OK"
    credits { rand(10) }
    refundable_credits { rand(10) }
    credit_value { rand(10) }
    payment_gateway { [nil, "braintree", "stripe"].sample }
    payment_method { %w(bank_account epg).sample }
    final_balance { rand(10) }
    final_refundable_balance { rand(10) }
  end

  factory :credential_transaction do
    transaction_type { "word #{rand(100)}" }
    device_created_at { Time.zone.now }
    customer_tag_uid { SecureRandom.urlsafe_base64.upcase }
    operator_tag_uid { SecureRandom.urlsafe_base64.upcase }
    device_uid { "word #{rand(100)}" }
    status_code "0"
    status_message "OK"
  end

  factory :access_transaction do
    transaction_type { "word #{rand(100)}" }
    device_created_at { Time.zone.now }
    customer_tag_uid { SecureRandom.urlsafe_base64.upcase }
    operator_tag_uid { SecureRandom.urlsafe_base64.upcase }
    device_uid { "word #{rand(100)}" }
    status_code "0"
    status_message "OK"
    direction { rand(2) }
  end

  factory :order_transaction do
    transaction_type { "word #{rand(100)}" }
    device_created_at { Time.zone.now }
    customer_tag_uid { SecureRandom.urlsafe_base64.upcase }
    operator_tag_uid { SecureRandom.urlsafe_base64.upcase }
    device_uid { "word #{rand(100)}" }
    status_code "0"
    status_message "OK"
  end
end
