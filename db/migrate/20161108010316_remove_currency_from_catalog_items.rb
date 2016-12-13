class RemoveCurrencyFromCatalogItems < ActiveRecord::Migration
  def change
    remove_column :catalog_items, :currency, :string
  end
end
