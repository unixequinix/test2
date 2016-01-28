class CreatePreeventItems < ActiveRecord::Migration
  def change
    create_table :preevent_items do |t|
      t.references :purchasable, polymorphic: true, null: false
      t.integer :event_id, index: true
      t.string :name
      t.text :description

      t.datetime :deleted_at, index: true
      t.timestamps null: false
    end
  end
end
