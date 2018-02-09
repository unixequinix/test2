class Device < ApplicationRecord
  include Alertable

  has_many :device_registrations, dependent: :destroy
  has_many :events, through: :device_registrations, dependent: :destroy
  has_many :device_transactions, dependent: :restrict_with_error

  validates :mac, uniqueness: true, allow_blank: false
  validates :mac, presence: true

  def name
    "#{mac}: #{asset_tracker.blank? ? 'Unnamed' : asset_tracker}"
  end

  def small_name
    asset_tracker.blank? ? mac : asset_tracker
  end
end
