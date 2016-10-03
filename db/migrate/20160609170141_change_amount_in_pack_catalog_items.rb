class ChangeAmountInPackCatalogItems < ActiveRecord::Migration
  def change
    change_column :pack_catalog_items, :amount, :decimal, precision: 8, scale: 2
  end
end
