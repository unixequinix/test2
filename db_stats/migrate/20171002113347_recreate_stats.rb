class RecreateStats < ActiveRecord::Migration[5.1]
  def change
    create_table :stats do |t|
      t.string :action, null: false
      t.string :name
      t.bigint :operation_id, null: false
      t.string :origin, null: false
      t.datetime :date, null: false
      t.bigint :event_id, null: false
      t.string :event_name, null: false
      t.integer :line_counter, null: false, default: 1
      t.bigint :device_id
      t.string :device_mac
      t.string :device_name
      t.bigint :station_id
      t.string :station_type
      t.string :station_name
      t.string :operator_uid
      t.string :operator_name
      t.bigint :event_series_id
      t.string :event_series_name
      t.bigint :customer_id
      t.string :customer_name
      t.string :customer_email
      t.string :customer_uid
      t.integer :gtag_counter
      t.string :credential_code
      t.string :credential_type
      t.string :purchaser_name
      t.string :purchaser_email
      t.bigint :ticket_type_id
      t.string :ticket_type_name
      t.bigint :company_id
      t.string :company_name
      t.bigint :product_id
      t.string :product_name
      t.boolean :is_alcohol
      t.integer :sale_item_quantity
      t.decimal :sale_item_unit_price, precision: 10, scale: 2
      t.decimal :sale_item_total_price, precision: 10, scale: 2
      t.bigint :catalog_item_id
      t.string :catalog_item_name
      t.string :catalog_item_type
      t.string :direction
      t.string :direction_counter
      t.string :payment_method
      t.integer :monetary_quantity
      t.decimal :monetary_unit_price, precision: 8, scale: 2
      t.string :currency
      t.decimal :monetary_total_price, precision: 8, scale: 2
      t.bigint :credit_id
      t.string :credit_name
      t.decimal :credit_value, precision: 8, scale: 2
      t.decimal :credit_amount, precision: 8, scale: 2
      t.decimal :final_balance, precision: 8, scale: 2
      t.bigint :order_id
      t.string :message
      t.integer :priority
      t.boolean :user_flag_value
      t.integer :access_direction
    end

    add_index(:stats, %i[operation_id line_counter], unique: true, using: :btree)
  end
end
