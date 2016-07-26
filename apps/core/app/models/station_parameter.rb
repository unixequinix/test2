# == Schema Information
#
# Table name: station_parameters
#
#  id                       :integer          not null, primary key
#  station_id               :integer          not null
#  station_parametable_id   :integer          not null
#  station_parametable_type :string           not null
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#

class StationParameter < ActiveRecord::Base
  # Associations
  belongs_to :station, touch: true
  belongs_to :station_parametable, polymorphic: true, touch: true
end
