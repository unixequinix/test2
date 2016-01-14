class CreatePreeventItems < ActiveRecord::Migration
  def change
    create_table :preevent_items do |t|
      t.references :purchasable, polymorphic: true, null: false
      t.integer :event_id
      t.string :name
      t.text :description
      t.integer :initial_amount
      t.decimal :price
      t.integer :step
      t.integer :max_purchasable
      t.integer :min_purchasable

      t.datetime :deleted_at, index: true
      t.timestamps null: false
    end
  end
end
