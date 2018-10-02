class AddPositionAndMaxBalanceToCatalogItems < ActiveRecord::Migration[5.1]
  def change
    add_column :catalog_items, :position, :integer
    add_column :catalog_items, :max_balance, :integer, default: 300
  end
end
