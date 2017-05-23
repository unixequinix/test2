class AddColumnConstraintsToPackCatalogItems < ActiveRecord::Migration[5.1]
  def change
    change_column_null :pack_catalog_items, :amount, false
    PackCatalogItem.where(amount: nil).update_all(amount: 0)
  end
end
