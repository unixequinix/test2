# == Schema Information
#
# Table name: station_groups
#
#  id         :integer          not null, primary key
#  name       :string           not null
#  icon_slug  :string           not null
#  deleted_at :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class StationGroup < ActiveRecord::Base
  has_many :station_types
  has_many :stations, through: :station_types
end
