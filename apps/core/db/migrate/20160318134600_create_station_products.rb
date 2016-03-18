class CreateStationProducts < ActiveRecord::Migration
  def change
    create_table :station_products do |t|
      t.references :product, null: false
      t.float :price, null: false

      t.datetime :deleted_at
      t.timestamps null: false
    end
  end
end
