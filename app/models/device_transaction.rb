class DeviceTransaction < ActiveRecord::Base
  belongs_to :event
  belongs_to :device

  ACTIONS = %w[device_initialization pack_device lock_device].freeze

  validates :action, :device_uid, :initialization_type, :number_of_transactions, presence: true
  validates :number_of_transactions, numericality: true
  validates :battery, numericality: { greater_than: 0 }, if: -> { battery.present? }
end
