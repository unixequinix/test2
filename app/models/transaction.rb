class Transaction < ActiveRecord::Base
  belongs_to :event
  belongs_to :station
  belongs_to :profile

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
  scope :not_record_credit, -> { where.not(transaction_type: "record_credit") }

  ORIGINS = { portal: "customer_portal", device: "onsite", admin: "admin_panel" }.freeze
  TYPES = %w(access ban credential credit money order device).freeze

  def category
    self.class.name.gsub("Transaction", "").downcase
  end

  def self.class_for_type(type)
    "#{type}_transaction".classify.constantize
  end

  def description
    "#{category.humanize} : #{transaction_type.humanize}"
  end

  def self.mandatory_fields
    %w( transaction_origin transaction_category transaction_type customer_tag_uid
        operator_tag_uid station_id device_uid device_db_index device_created_at status_code
        status_message )
  end
end
