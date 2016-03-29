# == Schema Information
#
# Table name: station_types
#
#  id               :integer          not null, primary key
#  station_group_id :integer          not null
#  name             :string           not null
#  environment      :string           not null
#  description      :text
#  deleted_at       :datetime
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class StationType < ActiveRecord::Base
  belongs_to :station_group
  has_many :stations
end
