class CreateStationCatalogItems < ActiveRecord::Migration
  def change
    create_table :station_catalog_items do |t|
      t.integer :catalog_item_id, null: false
      t.float :price, null: false

      t.timestamps null: false
    end
  end
end
