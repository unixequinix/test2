class CreateOrderItems < ActiveRecord::Migration
  def change
    create_table :order_items do |t|
      t.references :order, null: false
      t.references :catalog_item, null: false
      t.integer :amount
      t.decimal :total, precision: 8, scale: 2, null: false

      t.datetime :deleted_at, index: true
      t.timestamps null: false
    end
  end
end
