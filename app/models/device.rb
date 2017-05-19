class Device < ActiveRecord::Base
  has_many :device_registrations
  has_many :events, through: :device_registrations

  validates :mac, uniqueness: true

  attr_accessor :msg, :action, :status, :operator, :station, :last_time_used, :server_transactions, :number_of_transactions, :live, :live_time
end
