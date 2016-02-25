class CreatePacksCatalogItems < ActiveRecord::Migration
  def change
    create_table :packs_catalog_items do |t|
      t.references :pack, null: false, index: true
      t.references  :catalog_item, null: false, index: true
      t.integer  :amount

      t.datetime :deleted_at, index: true
      t.timestamps null: false
    end
  end
end
