class CreateOnlineProducts < ActiveRecord::Migration
  def change
    create_table :online_products do |t|
      t.string :name, null: false
      t.string :description, null: false
      t.decimal :price, precision: 8, scale: 2, null: false
      t.references :purchasable, polymorphic: true, null: false

      t.timestamps null: false
    end
  end
end
