class RenameCatalogableIdToCatalogItemIdInTransactions < ActiveRecord::Migration
  def change
    rename_column :transactions, :catalogable_id, :catalog_item_id
  end
end
