# == Schema Information
#
# Table name: stations
#
#  id              :integer          not null, primary key
#  event_id        :integer          not null
#  station_type_id :integer          not null
#  name            :string           not null
#  deleted_at      :datetime
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class Station < ActiveRecord::Base
  belongs_to :event
  belongs_to :station_type

  has_many :station_parameters, as: :station_parametable, dependent: :destroy
  has_many :station_catalog_items, through: :station_parameters,
                                   source: :station_parametable,
                                   source_type: "StationCatalogItem"

  accepts_nested_attributes_for :station_catalog_items, allow_destroy: true

  validates :station_type, presence: true

  SALE_STATIONS = [:customer_portal, :pos, :box_office]
  TOPUP_STATIONS = [:topup]

  def unassigned_catalog_items
    CatalogItem.where("id NOT IN (
                       SELECT station_catalog_items.catalog_item_id FROM station_catalog_items
                       INNER JOIN station_parameters
                       ON station_catalog_items.id = station_parameters.station_parametable_id
                       AND station_parameters.station_parametable_type = 'StationCatalogItem'
                       WHERE station_id = #{id})")
  end
end
