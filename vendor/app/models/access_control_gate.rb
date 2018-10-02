class AccessControlGate < ApplicationRecord
  belongs_to :access
  belongs_to :station, touch: true

  validates :direction, presence: true
  validates :access_id, uniqueness: { scope: :station_id }

  scope(:in, -> { where(direction: "1") })
  scope(:out, -> { where(direction: "-1") })

  before_update :check_station_visibility

  def self.policy_class
    StationItemPolicy
  end

  def self.sort_column
    :access_id
  end

  private

  # If all gates are hidden, the sation must be hidden, if one is visible, station must be visible.
  def check_station_visibility
    station.update(hidden: station.access_control_gates.where.not(id: id).pluck(:hidden).push(hidden).uniq.all?) if hidden_changed?
  end
end
