class Device < ApplicationRecord
  include Alertable

  belongs_to :team
  has_many :device_registrations, dependent: :destroy
  has_many :events, through: :device_registrations, dependent: :destroy
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
