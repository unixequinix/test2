class Transaction < ActiveRecord::Base
  self.abstract_class = true

  belongs_to :event
  belongs_to :station
  belongs_to :profile

  validates_presence_of :transaction_type

  TYPES = %w(access ban credential credit money order device).freeze

  def self.class_for_type(type)
    "#{type}_transaction".classify.constantize
  end

  def self.mandatory_fields
    %w( transaction_origin transaction_category transaction_type customer_tag_uid
        operator_tag_uid station_id device_uid device_db_index device_created_at status_code
        status_message )
  end
end
