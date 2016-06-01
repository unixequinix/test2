class AddPositionToStationProducts < ActiveRecord::Migration
  def change
    add_column :station_products, :position, :integer
  end
end
