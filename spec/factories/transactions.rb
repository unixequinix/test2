FactoryGirl.define do
  factory :money_transaction do
    sequence(:action) { |n| "action #{n}" }
    transaction_origin Transaction::ORIGINS[:device]
    device_created_at { Time.zone.now }
    customer_tag_uid { SecureRandom.urlsafe_base64.upcase }
    operator_tag_uid { SecureRandom.urlsafe_base64.upcase }
    sequence(:device_uid) { |n| "DEVICE#{n}" }
    status_code "0"
    status_message "OK"
    sequence(:items_amount)
    sequence(:price)
    payment_gateway "paypal"
    payment_method { %w[bank_account epg].sample }
  end

  factory :credit_transaction do
    sequence(:action) { |n| "action #{n}" }
    transaction_origin Transaction::ORIGINS[:device]
    device_created_at { Time.zone.now }
    customer_tag_uid { SecureRandom.urlsafe_base64.upcase }
    operator_tag_uid { SecureRandom.urlsafe_base64.upcase }
    sequence(:device_uid) { |n| "DEVICE#{n}" }
    status_code "0"
    status_message "OK"
    sequence(:credits)
    sequence(:refundable_credits)
    sequence(:final_balance)
    sequence(:final_refundable_balance)
  end

  factory :credential_transaction do
    sequence(:action) { |n| "action #{n}" }
    transaction_origin Transaction::ORIGINS[:device]
    device_created_at { Time.zone.now }
    customer_tag_uid { SecureRandom.urlsafe_base64.upcase }
    operator_tag_uid { SecureRandom.urlsafe_base64.upcase }
    sequence(:device_uid) { |n| "DEVICE#{n}" }
    status_code "0"
    status_message "OK"
  end

  factory :access_transaction do
    sequence(:action) { |n| "action #{n}" }
    transaction_origin Transaction::ORIGINS[:device]
    device_created_at { Time.zone.now }
    customer_tag_uid { SecureRandom.urlsafe_base64.upcase }
    operator_tag_uid { SecureRandom.urlsafe_base64.upcase }
    sequence(:device_uid) { |n| "DEVICE#{n}" }
    status_code "0"
    status_message "OK"
    direction 1
  end

  factory :order_transaction do
    sequence(:action) { |n| "action #{n}" }
    transaction_origin Transaction::ORIGINS[:device]
    device_created_at { Time.zone.now }
    customer_tag_uid { SecureRandom.urlsafe_base64.upcase }
    operator_tag_uid { SecureRandom.urlsafe_base64.upcase }
    sequence(:device_uid) { |n| "DEVICE#{n}" }
    status_code "0"
    status_message "OK"
  end

  factory :transaction do
    sequence(:action) { |n| "action #{n}" }
    transaction_origin Transaction::ORIGINS[:device]
    device_created_at { Time.zone.now }
    customer_tag_uid { SecureRandom.urlsafe_base64.upcase }
    operator_tag_uid { SecureRandom.urlsafe_base64.upcase }
    sequence(:device_uid) { |n| "DEVICE#{n}" }
    status_code "0"
    status_message "OK"
  end
end
