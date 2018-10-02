class AddSpendingOrderOnCatalogItems < ActiveRecord::Migration[5.1]
  def change
    add_column :catalog_items, :spending_order, :integer, allow: nil
  end
end
