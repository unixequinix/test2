class RemoveOldProducts < ActiveRecord::Migration[5.1]
  def change
    remove_column :sale_items, :old_product_id, :integer
    remove_column :products, :old_product_id, :integer
    drop_table :old_products
  end
end
