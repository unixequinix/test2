class CreatePreeventProductItems < ActiveRecord::Migration
  def change
    create_table :preevent_product_items do |t|
      t.integer :preevent_item_id
      t.integer :preevent_product_id
      t.integer :amount

      t.datetime :deleted_at, index: true
      t.timestamps null: false
    end
  end
end
