# == Schema Information
#
# Table name: access_control_gates
#
#  direction  :string           not null
#
# Indexes
#
#  index_access_control_gates_on_access_id   (access_id)
#  index_access_control_gates_on_station_id  (station_id)
#
# Foreign Keys
#
#  fk_rails_1846655ccd  (station_id => stations.id)
#

class AccessControlGate < ActiveRecord::Base
  belongs_to :access
  belongs_to :station, touch: true

  validates :direction, :access_id, presence: true

  scope :in, -> { where(direction: "1") }
  scope :out, -> { where(direction: "-1") }

  def self.policy_class
    StationItemPolicy
  end

  def self.sort_column
    :access_id
  end
end
