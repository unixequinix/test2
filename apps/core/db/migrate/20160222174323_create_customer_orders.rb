class CreateCustomerOrders < ActiveRecord::Migration
  def change
    create_table :customer_orders do |t|
      t.references :customer_event_profile, null: false
      t.references :catalog_item, null: false
      t.integer :counter

      t.datetime :deleted_at, index: true
      t.timestamps null: false
    end
  end
end
