class Device < ApplicationRecord
  include Alertable

  belongs_to :team
  has_many :device_registrations, dependent: :destroy
  has_many :events, through: :device_registrations, dependent: :destroy
  has_one :device_registration, -> { where(allowed: false) }, dependent: :destroy, inverse_of: :device
  has_one :event, through: :device_registration, dependent: :destroy
  has_many :device_transactions, dependent: :restrict_with_error
  has_many :pokes, dependent: :restrict_with_error

  validates :asset_tracker, uniqueness: { case_sensitive: false, scope: :team_id }, allow_blank: true
  validates :mac, uniqueness: { case_sensitive: true, scope: :team_id }, presence: true

  before_save :format_mac, :format_asset_tracker

  def name
    "#{mac}: #{asset_tracker.presence || 'Unnamed'}"
  end

  def small_name
    asset_tracker.presence || mac
  end

  def events_for_device
    ids = event.present? ? [event.id] : team.event_ids
    Event.where(id: ids, open_devices_api: true).launched
  end

  private

  def format_mac
    self.mac = mac.downcase
  end

  def format_asset_tracker
    self.asset_tracker = asset_tracker.presence
  end
end
