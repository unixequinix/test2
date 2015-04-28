class CreateOnlineProducts < ActiveRecord::Migration
  def change
    create_table :online_products do |t|
      t.string :name
      t.text :description
      t.decimal :price, precision: 8, scale: 2

      t.timestamps null: false
    end
  end
end
