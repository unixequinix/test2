class CreateCustomerOrders < ActiveRecord::Migration
  def change
    create_table :customer_orders do |t|
      t.integer :preevent_product_id, null: false
      t.integer :customer_event_profile_id, null: false
      t.integer :counter
      t.string  :aasm_state, null: false, default: "unredeemed"

      t.datetime :deleted_at, index: true
      t.timestamps null: false
    end
  end
end
