FactoryGirl.define do
  factory :money_transaction do
    event
    station
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
    station
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
    station
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
    station
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
    station
    order
    sequence(:action) { |n| "action #{n}" }
    sequence(:device_db_index)
    transaction_origin Transaction::ORIGINS[:device]
    device_created_at { Time.zone.now }
    customer_tag_uid { SecureRandom.hex(14).upcase }
    operator_tag_uid { SecureRandom.hex(14).upcase }
    sequence(:device_uid) { |n| "DEVICE#{n}" }
  end

  factory :user_engagement_transaction do
    event
    station
    order
    action "exhibitor_note"
    sequence(:device_db_index)
    message "i love Glownet! "
    sequence(:priority)
    transaction_origin Transaction::ORIGINS[:device]
    device_created_at { Time.zone.now }
    customer_tag_uid { SecureRandom.hex(14).upcase }
    operator_tag_uid { SecureRandom.hex(14).upcase }
    sequence(:device_uid) { |n| "DEVICE#{n}" }
  end

  factory :user_flag_transaction do
    event
    station
    order
    action "exhibitor_note"
    sequence(:device_db_index)
    user_flag_active true
    user_flag "yellow_flag"
    transaction_origin Transaction::ORIGINS[:device]
    device_created_at { Time.zone.now }
    customer_tag_uid { SecureRandom.hex(14).upcase }
    operator_tag_uid { SecureRandom.hex(14).upcase }
    sequence(:device_uid) { |n| "DEVICE#{n}" }
  end

  factory :transaction do
    event
    station
    sequence(:action) { |n| "action #{n}" }
    sequence(:device_db_index)
    transaction_origin Transaction::ORIGINS[:device]
    device_created_at { Time.zone.now }
    customer_tag_uid { SecureRandom.hex(14).upcase }
    operator_tag_uid { SecureRandom.hex(14).upcase }
    sequence(:device_uid) { |n| "DEVICE#{n}" }
  end
end
