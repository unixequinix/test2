class CreatePreeventProducts < ActiveRecord::Migration
  def change
    create_table :preevent_products do |t|
      t.integer :event_id, null: false
      t.string :name
      t.boolean :online, default: false, null: false

      t.datetime :deleted_at, index: true
      t.timestamps null: false
    end
  end
end