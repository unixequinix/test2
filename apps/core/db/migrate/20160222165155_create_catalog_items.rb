class CreateCatalogItems < ActiveRecord::Migration
  def change
    create_table :catalog_items do |t|
      t.references :event, null: false, index: true
      t.references :catalogable, polymorphic: true, null: false
      t.string :name
      t.text :description
      t.integer :initial_amount
      t.integer :step
      t.integer :max_purchasable
      t.integer :min_purchasable

      t.datetime :deleted_at, index: true
      t.timestamps null: false
    end
  end
end