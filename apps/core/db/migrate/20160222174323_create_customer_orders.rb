class CreateCustomerOrders < ActiveRecord::Migration
  def change
    create_table :customer_orders do |t|
      t.references :customer_event_profile
      t.references :catalog_item
      t.integer :counter
      t.boolean :redeemed, default: false, null: false

      t.datetime :deleted_at, index: true
      t.timestamps null: false
    end
  end
end