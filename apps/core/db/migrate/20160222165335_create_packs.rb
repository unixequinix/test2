class CreatePacks < ActiveRecord::Migration
  def change
    create_table :packs do |t|
      t.integer :catalog_items_count, default: 0, null: false

      t.datetime :deleted_at, index: true
      t.timestamps null: false
    end
  end
end