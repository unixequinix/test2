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
  belongs_to :station
  belongs_to :station_parametable, polymorphic: true
  has_one :station_catalog_item, as: :station_parametable, dependent: :destroy
  accepts_nested_attributes_for :station_catalog_item, allow_destroy: true
end
