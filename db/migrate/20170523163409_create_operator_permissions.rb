class CreateOperatorPermissions < ActiveRecord::Migration[5.1]
  def change
    add_column :catalog_items, :role, :integer, default: 1, null: false
    add_column :catalog_items, :station_id, :integer
    add_column :catalog_items, :group, :integer

    add_index :catalog_items, :station_id
    add_index :catalog_items, [:station_id, :group, :role], unique: true
    add_foreign_key :catalog_items, :stations
  end
end
