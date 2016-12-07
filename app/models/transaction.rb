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
#  transaction_origin          :string
#  type                        :string
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

class Transaction < ActiveRecord::Base
  belongs_to :event
  belongs_to :station
  belongs_to :customer
  belongs_to :gtag

  scope :credit, -> { where(type: "CreditTransaction") }
  scope :credential, -> { where(type: "CredentialTransaction") }
  scope :access, -> { where(type: "AccessTransaction") }
  scope :money, -> { where(type: "MoneyTransaction") }
  scope :ban, -> { where(type: "BanTransaction") }
  scope :orders, -> { where(type: "OrderTransaction") }
  scope :device, -> { where(type: "DeviceTransaction") }

  scope :with_event, -> (event) { where(event: event) }
  scope :with_customer_tag, -> (tag_uid) { where(customer_tag_uid: tag_uid) }
  scope :status_ok, -> { where(status_code: 0) }
  scope :origin, -> (origin) { where(transaction_origin: Transaction::ORIGINS[origin]) }
  scope :not_record_credit, -> { where.not(action: "record_credit") }

  ORIGINS = { portal: "customer_portal", device: "onsite", admin: "admin_panel" }.freeze
  TYPES = %w(access credential credit money order operator user_engagement).freeze
  
  def category
    type.gsub("Transaction", "").downcase
  end

  def self.class_for_type(type)
    "#{type}_transaction".classify.constantize
  end

  def description
    "#{category.humanize} : #{action.humanize}"
  end

  def self.mandatory_fields
    %w( action customer_tag_uid operator_tag_uid station_id device_uid device_db_index device_created_at status_code status_message ) # rubocop:disable Metrics/LineLength
  end
end
