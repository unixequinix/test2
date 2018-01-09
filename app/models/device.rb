class Device < ApplicationRecord
  include Alertable

  # TODO: remove optional: true form team when all devices have a team
  belongs_to :team, optional: true
  has_many :device_registrations, dependent: :destroy
  has_many :events, through: :device_registrations, dependent: :destroy
  has_one :device_registration, -> { where(allowed: false) }, dependent: :destroy, inverse_of: :device
  has_one :event, through: :device_registration, dependent: :destroy
  has_many :device_transactions, dependent: :restrict_with_error

  validates :asset_tracker, uniqueness: { case_sensitive: false, scope: :team_id }, allow_blank: true
  validates :mac, uniqueness: { case_sensitive: false, scope: :team_id }, presence: true

  def name
    "#{mac}: #{asset_tracker.presence || 'Unnamed'}"
  end

  def small_name
    asset_tracker.presence || mac
  end
end
