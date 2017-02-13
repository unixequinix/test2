# == Schema Information
#
# Table name: transactions
#
#  action                   :string
#  counter                  :integer
#  credits                  :float
#  device_db_index          :integer
#  direction                :integer
#  executed                 :boolean
#  final_access_value       :string
#  final_balance            :float
#  final_refundable_balance :float
#  gtag_counter             :integer
#  items_amount             :float
#  message                  :string
#  operator_value           :string
#  order_item_counter       :integer
#  payment_gateway          :string
#  payment_method           :string
#  price                    :float
#  priority                 :integer
#  refundable_credits       :float
#  status_code              :integer
#  status_message           :string
#  ticket_code              :citext
#  transaction_origin       :string
#  type                     :string
#  user_flag                :string
#  user_flag_active         :boolean
#
# Indexes
#
#  index_transactions_on_access_id            (access_id)
#  index_transactions_on_action               (action)
#  index_transactions_on_catalog_item_id      (catalog_item_id)
#  index_transactions_on_customer_id          (customer_id)
#  index_transactions_on_device_columns       (event_id,device_uid,device_db_index,device_created_at_fixed,gtag_counter) UNIQUE
#  index_transactions_on_event_id             (event_id)
#  index_transactions_on_gtag_id              (gtag_id)
#  index_transactions_on_operator_station_id  (operator_station_id)
#  index_transactions_on_order_id             (order_id)
#  index_transactions_on_station_id           (station_id)
#  index_transactions_on_ticket_id            (ticket_id)
#  index_transactions_on_type                 (type)
#
# Foreign Keys
#
#  fk_rails_091c1eea0c  (ticket_id => tickets.id)
#  fk_rails_35e85c4b19  (catalog_item_id => catalog_items.id)
#  fk_rails_4855921d15  (event_id => events.id)
#  fk_rails_59d791a33f  (order_id => orders.id)
#  fk_rails_984bd8f159  (customer_id => customers.id)
#  fk_rails_9bf7d8b3a6  (gtag_id => gtags.id)
#  fk_rails_f51c7f5cfc  (station_id => stations.id)
#

FactoryGirl.define do
  factory :money_transaction do
    sequence(:action) { |n| "action #{n}" }
    device_created_at { Time.zone.now }
    customer_tag_uid { SecureRandom.urlsafe_base64.upcase }
    operator_tag_uid { SecureRandom.urlsafe_base64.upcase }
    sequence(:device_uid) { |n| "DEVICE#{n}" }
    status_code "0"
    status_message "OK"
    sequence(:items_amount)
    sequence(:price)
    payment_gateway { [nil, "braintree", "stripe"].sample }
    payment_method { %w(bank_account epg).sample }
  end

  factory :credit_transaction do
    sequence(:action) { |n| "action #{n}" }
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
    device_created_at { Time.zone.now }
    customer_tag_uid { SecureRandom.urlsafe_base64.upcase }
    operator_tag_uid { SecureRandom.urlsafe_base64.upcase }
    sequence(:device_uid) { |n| "DEVICE#{n}" }
    status_code "0"
    status_message "OK"
  end

  factory :access_transaction do
    sequence(:action) { |n| "action #{n}" }
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
    device_created_at { Time.zone.now }
    customer_tag_uid { SecureRandom.urlsafe_base64.upcase }
    operator_tag_uid { SecureRandom.urlsafe_base64.upcase }
    sequence(:device_uid) { |n| "DEVICE#{n}" }
    status_code "0"
    status_message "OK"
  end

  factory :transaction do
    sequence(:action) { |n| "action #{n}" }
    device_created_at { Time.zone.now }
    customer_tag_uid { SecureRandom.urlsafe_base64.upcase }
    operator_tag_uid { SecureRandom.urlsafe_base64.upcase }
    sequence(:device_uid) { |n| "DEVICE#{n}" }
    status_code "0"
    status_message "OK"
  end
end
