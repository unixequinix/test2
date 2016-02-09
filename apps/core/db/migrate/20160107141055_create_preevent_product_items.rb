class CreatePreeventProductItems < ActiveRecord::Migration
  def change
    create_table :preevent_product_items do |t|
      t.integer :preevent_item_id
      t.integer :preevent_product_id
      t.decimal :amount, precision: 8, scale: 2, default: 1.0, null: false
      t.integer :preevent_items_count, default: 0, null: false

      t.datetime :deleted_at, index: true
      t.timestamps null: false
    end
  end
end
