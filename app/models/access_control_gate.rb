# == Schema Information
#
# Table name: access_control_gates
#
#  created_at :datetime         not null
#  direction  :string           not null
#  updated_at :datetime         not null
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
  belongs_to :station

  validates :direction, :access_id, presence: true

  after_update { station.touch }
end
