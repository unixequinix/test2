class AddDefaultToPackCatalogItem < ActiveRecord::Migration[5.1]
  def change
    change_column :pack_catalog_items, :amount, :integer
    change_column_default :pack_catalog_items, :amount, from: nil, to: 1
  end
end
