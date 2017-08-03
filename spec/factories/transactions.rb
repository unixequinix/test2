FactoryGirl.define do
  factory :money_transaction do
    event
    sequence(:action) { |n| "action #{n}" }
    sequence(:device_db_index)
    transaction_origin Transaction::ORIGINS[:device]
    device_created_at { Time.zone.now }
    customer_tag_uid { SecureRandom.hex(14).upcase }
    operator_tag_uid { SecureRandom.hex(14).upcase }
    sequence(:device_uid) { |n| "DEVICE#{n}" }
    sequence(:items_amount)
    sequence(:price)
    payment_gateway "paypal"
    payment_method { %w[bank_account epg].sample }
  end

  factory :credit_transaction do
    event
    sequence(:action) { |n| "action #{n}" }
    sequence(:device_db_index)
    transaction_origin Transaction::ORIGINS[:device]
    device_created_at { Time.zone.now }
    customer_tag_uid { SecureRandom.hex(14).upcase }
    operator_tag_uid { SecureRandom.hex(14).upcase }
    sequence(:device_uid) { |n| "DEVICE#{n}" }
    sequence(:credits)
    sequence(:refundable_credits)
    sequence(:final_balance)
    sequence(:final_refundable_balance)
  end

  factory :credential_transaction do
    event
    sequence(:action) { |n| "action #{n}" }
    sequence(:device_db_index)
    transaction_origin Transaction::ORIGINS[:device]
    device_created_at { Time.zone.now }
    customer_tag_uid { SecureRandom.hex(14).upcase }
    operator_tag_uid { SecureRandom.hex(14).upcase }
    sequence(:device_uid) { |n| "DEVICE#{n}" }
  end

  factory :access_transaction do
    event
    sequence(:action) { |n| "action #{n}" }
    sequence(:device_db_index)
    transaction_origin Transaction::ORIGINS[:device]
    device_created_at { Time.zone.now }
    customer_tag_uid { SecureRandom.hex(14).upcase }
    operator_tag_uid { SecureRandom.hex(14).upcase }
    sequence(:device_uid) { |n| "DEVICE#{n}" }
    direction 1
  end

  factory :order_transaction do
    event
    order
    sequence(:action) { |n| "action #{n}" }
    sequence(:device_db_index)
    transaction_origin Transaction::ORIGINS[:device]
    device_created_at { Time.zone.now }
    customer_tag_uid { SecureRandom.hex(14).upcase }
    operator_tag_uid { SecureRandom.hex(14).upcase }
    sequence(:device_uid) { |n| "DEVICE#{n}" }
  end

  factory :transaction do
    event
    sequence(:action) { |n| "action #{n}" }
    sequence(:device_db_index)
    transaction_origin Transaction::ORIGINS[:device]
    device_created_at { Time.zone.now }
    customer_tag_uid { SecureRandom.hex(14).upcase }
    operator_tag_uid { SecureRandom.hex(14).upcase }
    sequence(:device_uid) { |n| "DEVICE#{n}" }
  end
end
