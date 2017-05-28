class Device < ApplicationRecord
  has_many :device_registrations
  has_many :events, through: :device_registrations
  has_many :device_transactions, dependent: :restrict_with_error

  validates :mac, uniqueness: true

  attr_accessor :msg, :action, :status, :operator, :station, :last_time_used,
                :server_transactions, :number_of_transactions, :live, :live_time, :battery, :app_version
end
