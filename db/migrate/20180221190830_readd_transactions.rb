class ReaddTransactions < ActiveRecord::Migration[5.1]
  def change
    return if table_exists?(:transactions)
    create_table "transactions" do |t|
      t.integer "event_id", null: false
      t.string "type", null: false
      t.string "transaction_origin", null: false
      t.string "action", null: false
      t.citext "customer_tag_uid"
      t.citext "operator_tag_uid"
      t.integer "station_id"
      t.string "device_uid"
      t.integer "device_db_index"
      t.string "device_created_at", null: false
      t.string "device_created_at_fixed"
      t.integer "gtag_counter"
      t.integer "counter"
      t.string "status_message"
      t.integer "status_code", default: 0, null: false
      t.integer "access_id"
      t.integer "direction"
      t.string "final_access_value"
      t.string "message"
      t.citext "ticket_code"
      t.float "credits"
      t.float "refundable_credits"
      t.float "final_balance"
      t.float "final_refundable_balance"
      t.integer "catalog_item_id"
      t.float "items_amount"
      t.float "price"
      t.string "payment_method"
      t.string "payment_gateway"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.integer "ticket_id"
      t.integer "priority"
      t.string "operator_value"
      t.integer "operator_station_id"
      t.integer "order_id"
      t.integer "gtag_id"
      t.integer "customer_id"
      t.boolean "executed"
      t.string "user_flag"
      t.boolean "user_flag_active"
      t.float "other_amount_credits"
      t.jsonb "payments", default: {}
      t.integer "operator_id"
      t.bigint "operator_gtag_id"
      t.bigint "order_item_id"
      t.index :access_id
      t.index :action
      t.index :catalog_item_id
      t.index :customer_id
      t.index :device_uid
      t.index ["event_id", "device_uid", "device_db_index", "device_created_at_fixed", "gtag_counter"], unique: true, name: "index_transactions_on_device_columns"
      t.index :event_id
      t.index :gtag_id
      t.index :operator_id
      t.index :operator_station_id
      t.index :order_id
      t.index :station_id
      t.index :ticket_id
      t.index :type
    end

    return if table_exists?(:sale_items)
    create_table "sale_items" do |t|
      t.integer "quantity", null: false
      t.float "standard_unit_price"
      t.integer "credit_transaction_id", null: false
      t.bigint "product_id"
      t.string "sale_item_type"
      t.jsonb "payments", default: {}
      t.decimal "standard_total_price", precision: 10, scale: 2
      t.index :credit_transaction_id
      t.index :product_id
    end
  end
end
