class CreatePreeventProducts < ActiveRecord::Migration
  def change
    create_table :preevent_products do |t|
      t.integer :event_id, null: false, index: true
      t.string :name
      t.boolean :online, default: false, null: false
      t.integer :initial_amount
      t.integer :step
      t.integer :max_purchasable
      t.integer :min_purchasable
      t.decimal :price
      t.integer :preevent_items_count, default: 0, null: false

      t.datetime :deleted_at, index: true
      t.timestamps null: false
    end
  end
end
