# == Schema Information
#
# Table name: transactions
#
#  action                      :string
#  activation_counter          :integer
#  counter                     :integer
#  credits                     :float
#  device_db_index             :integer
#  direction                   :integer
#  executed                    :boolean
#  final_access_value          :string
#  final_balance               :float
#  final_refundable_balance    :float
#  gtag_counter                :integer
#  items_amount                :float
#  message                     :string
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
#  ticket_code                 :citext
#  transaction_origin          :string
#  type                        :string
#
# Indexes
#
#  index_transactions_on_access_id            (access_id)
#  index_transactions_on_catalog_item_id      (catalog_item_id)
#  index_transactions_on_customer_id          (customer_id)
#  index_transactions_on_device_columns       (event_id,device_uid,device_db_index,device_created_at_fixed,gtag_counter,activation_counter) UNIQUE
#  index_transactions_on_event_id             (event_id)
#  index_transactions_on_gtag_id              (gtag_id)
#  index_transactions_on_gtag_id_and_type     (gtag_id,type)
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

class CreditTransaction < Transaction
  belongs_to :customer
  has_many :sale_items, foreign_key: 'credit_transaction_id'

  accepts_nested_attributes_for :sale_items

  def description
    refundables = ": R #{refundable_credits} #{event.token_symbol}" if credits != refundable_credits
    "#{action.humanize} #{refundables}"
  end

  def self.mandatory_fields
    super + %w(credits refundable_credits credit_value final_balance final_refundable_balance)
  end

  def self.column_names
    super + %w(sale_items_attributes)
  end

  def self.policy_class
    TransactionPolicy
  end
end
