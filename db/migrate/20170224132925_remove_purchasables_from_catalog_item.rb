class RemovePurchasablesFromCatalogItem < ActiveRecord::Migration[5.0]
  def change
    remove_column :catalog_items, :initial_amount, :integer
    remove_column :catalog_items, :min_purchasable, :integer
    remove_column :catalog_items, :max_purchasable, :integer
    remove_column :catalog_items, :step, :integer

    add_column :events, :credit_step, :integer, default: 1
  end
end
