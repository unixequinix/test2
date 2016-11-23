# == Schema Information
#
# Table name: transactions
#
#  action                      :string
#  activation_counter          :integer
#  counter                     :integer
#  created_at                  :datetime         not null
#  credits                     :float
#  device_created_at           :string
#  device_created_at_fixed     :string
#  device_db_index             :integer
#  direction                   :integer
#  final_access_value          :string
#  final_balance               :float
#  final_refundable_balance    :float
#  gtag_counter                :integer
#  items_amount                :float
#  operator_activation_counter :integer
#  operator_value              :string
#  order_item_counter          :integer
#  payment_gateway             :string
#  payment_method              :string
#  price                       :float
#  priority                    :integer
#  refundable_credits          :float
#  status_code                 :integer
#  status_message              :string
#  ticket_code                 :string
#  transaction_category        :string
#  transaction_origin          :string
#  type                        :string
#  updated_at                  :datetime         not null
#
# Indexes
#
#  index_transactions_on_access_id            (access_id)
#  index_transactions_on_catalog_item_id      (catalog_item_id)
#  index_transactions_on_customer_id          (customer_id)
#  index_transactions_on_event_id             (event_id)
#  index_transactions_on_gtag_id              (gtag_id)
#  index_transactions_on_operator_station_id  (operator_station_id)
#  index_transactions_on_order_id             (order_id)
#  index_transactions_on_station_id           (station_id)
#  index_transactions_on_type                 (type)
#
# Foreign Keys
#
#  fk_rails_35e85c4b19  (catalog_item_id => catalog_items.id)
#  fk_rails_4855921d15  (event_id => events.id)
#  fk_rails_59d791a33f  (order_id => orders.id)
#  fk_rails_984bd8f159  (customer_id => customers.id)
#  fk_rails_9bf7d8b3a6  (gtag_id => gtags.id)
#  fk_rails_f51c7f5cfc  (station_id => stations.id)
#

FactoryGirl.define do
  factory :money_transaction do
    transaction_category "money"
    action { "word #{rand(100)}" }
    device_created_at { Time.zone.now }
    customer_tag_uid { SecureRandom.urlsafe_base64.upcase }
    operator_tag_uid { SecureRandom.urlsafe_base64.upcase }
    device_uid { "word #{rand(100)}" }
    status_code "0"
    status_message "OK"
    items_amount { rand(100) }
    price { rand(100) }
    payment_gateway { [nil, "braintree", "stripe"].sample }
    payment_method { %w(bank_account epg).sample }
  end

  factory :credit_transaction do
    action { "word #{rand(100)}" }
    device_created_at { Time.zone.now }
    customer_tag_uid { SecureRandom.urlsafe_base64.upcase }
    operator_tag_uid { SecureRandom.urlsafe_base64.upcase }
    device_uid { "word #{rand(100)}" }
    status_code "0"
    status_message "OK"
    credits { rand(10) }
    refundable_credits { rand(10) }
    final_balance { rand(10) }
    final_refundable_balance { rand(10) }
  end

  factory :credential_transaction do
    action { "word #{rand(100)}" }
    device_created_at { Time.zone.now }
    customer_tag_uid { SecureRandom.urlsafe_base64.upcase }
    operator_tag_uid { SecureRandom.urlsafe_base64.upcase }
    device_uid { "word #{rand(100)}" }
    status_code "0"
    status_message "OK"
  end

  factory :access_transaction do
    action { "word #{rand(100)}" }
    device_created_at { Time.zone.now }
    customer_tag_uid { SecureRandom.urlsafe_base64.upcase }
    operator_tag_uid { SecureRandom.urlsafe_base64.upcase }
    device_uid { "word #{rand(100)}" }
    status_code "0"
    status_message "OK"
    direction { rand(2) }
  end

  factory :order_transaction do
    action { "word #{rand(100)}" }
    device_created_at { Time.zone.now }
    customer_tag_uid { SecureRandom.urlsafe_base64.upcase }
    operator_tag_uid { SecureRandom.urlsafe_base64.upcase }
    device_uid { "word #{rand(100)}" }
    status_code "0"
    status_message "OK"
  end

  factory :transaction do
    action { "word #{rand(100)}" }
    device_created_at { Time.zone.now }
    customer_tag_uid { SecureRandom.urlsafe_base64.upcase }
    operator_tag_uid { SecureRandom.urlsafe_base64.upcase }
    device_uid { "word #{rand(100)}" }
    status_code "0"
    status_message "OK"
  end
end
