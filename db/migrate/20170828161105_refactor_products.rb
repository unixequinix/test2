class RefactorProducts < ActiveRecord::Migration[5.1]
  def change
    add_column :station_products, :name, :string
    add_column :station_products, :is_alcohol, :boolean, default: false
    add_column :station_products, :description, :string
    add_column :station_products, :vat, :float, default: 0.0
    rename_column :station_products, :product_id, :old_product_id
    remove_index :station_products, :old_product_id
    change_column_null :station_products, :old_product_id, to: true, from: false

    remove_index :sale_items, :product_id
    remove_foreign_key :sale_items, :products
    rename_column :sale_items, :product_id, :old_product_id
    change_column_null :sale_items, :old_product_id, to: true, from: false


    rename_table :products, :old_products
    rename_table :station_products, :products

    add_reference :sale_items, :product, foreign_key: true, index: true
  end
end
