class Transaction < ActiveRecord::Base
  self.abstract_class = true

  belongs_to :event
  belongs_to :station
  belongs_to :profile

  validates_presence_of :transaction_type

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

  def last_known_balance
    profile.credit_transactions.where("gtag_counter <= ?", gtag_counter).last.try(:final_balance).to_f
  end

  def last_known_refundable_balance
    profile.credit_transactions.where("gtag_counter <= ?", gtag_counter).last.try(:final_refundable_balance).to_f
  end

  def self.mandatory_fields
    %w( transaction_origin transaction_category transaction_type customer_tag_uid
        operator_tag_uid station_id device_uid device_db_index device_created_at status_code
        status_message )
  end
end
