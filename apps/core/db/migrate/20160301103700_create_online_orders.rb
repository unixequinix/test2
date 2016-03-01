class CreateOnlineOrders < ActiveRecord::Migration
  def change
    create_table :online_orders do |t|
      t.references :customer_order, null: false
      t.integer :counter
      t.boolean :redeemed

      t.datetime :deleted_at, index: true
      t.timestamps null: false
    end
  end
end
