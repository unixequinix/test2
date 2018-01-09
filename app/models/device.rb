class Device < ApplicationRecord
  include Alertable

  belongs_to :team
  has_many :device_registrations, dependent: :destroy
  has_many :events, through: :device_registrations, dependent: :destroy
  has_one :device_registration, -> { where(allowed: false) }, dependent: :destroy, inverse_of: :device
  has_one :event, through: :device_registration, dependent: :destroy
  has_many :device_transactions, dependent: :restrict_with_error

  validates :mac, uniqueness: true, allow_blank: false
  validates :mac, presence: true

  def name
    "#{mac}: #{asset_tracker.presence || 'Unnamed'}"
  end

  def small_name
    asset_tracker.presence || mac
  end
end
