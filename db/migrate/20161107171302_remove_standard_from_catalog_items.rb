class RemoveStandardFromCatalogItems < ActiveRecord::Migration
  def change
    remove_column :catalog_items, :standard, :boolean, default: false
  end
end
