class Device < ApplicationRecord
  include Alertable

  has_many :device_registrations
  has_many :events, through: :device_registrations
  has_many :device_transactions, dependent: :restrict_with_error

  validates :mac, uniqueness: true

  def name
    "#{mac}: #{asset_tracker.blank? ? 'Unamed' : asset_tracker}"
  end
end
