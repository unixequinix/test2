class CreateCatalogItemsPacks < ActiveRecord::Migration
  def change
    create_table :catalog_items_packs do |t|
      t.references :pack, null: false, index: true
      t.references :catalog_item, null: false, index: true
      t.integer :amount

      t.timestamps null: false
    end
  end
end
