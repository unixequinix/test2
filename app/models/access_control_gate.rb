# == Schema Information
#
# Table name: access_control_gates
#
#  id         :integer          not null, primary key
#  access_id  :integer          not null
#  direction  :string           not null
#  deleted_at :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class AccessControlGate < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :access
  has_one :station_parameter, as: :station_parametable, dependent: :destroy
  accepts_nested_attributes_for :station_parameter, allow_destroy: true

  validates :direction, :access_id, presence: true

  after_update { station_parameter.station.touch }
end