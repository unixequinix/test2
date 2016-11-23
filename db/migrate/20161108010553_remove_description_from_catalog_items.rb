class RemoveDescriptionFromCatalogItems < ActiveRecord::Migration
  def change
    remove_column :catalog_items, :description, :text
  end
end
