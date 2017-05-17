class DeviceTransaction < ApplicationRecord
  belongs_to :event
  belongs_to :device

  validates :action, :device_uid, :initialization_type, :number_of_transactions, presence: true
  validates :number_of_transactions, numericality: true
  # validates :battery, numericality: { greater_than: 0 }, if: -> { battery.present? }
end
