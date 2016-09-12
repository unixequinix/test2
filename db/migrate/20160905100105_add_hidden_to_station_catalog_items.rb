class AddHiddenToStationCatalogItems < ActiveRecord::Migration
  def change
    add_column :station_catalog_items, :hidden, :boolean, default: false
  end
end
