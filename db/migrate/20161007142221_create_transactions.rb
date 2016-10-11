class CreateTransactions < ActiveRecord::Migration
  def change
    drop_table :transactions if ActiveRecord::Base.connection.table_exists? :transactions
    create_table :transactions do |t|
      t.references  :event, index: true
      t.references  :owner, polymorphic: true, index: true
      t.string   :type
      t.string   :transaction_origin
      t.string   :transaction_category
      t.string   :transaction_type
      t.string   :customer_tag_uid
      t.string   :operator_tag_uid
      t.references  :station, index: true
      t.string   :device_uid
      t.integer  :device_db_index
      t.string   :device_created_at
      t.string   :device_created_at_fixed
      t.integer  :gtag_counter
      t.integer  :counter
      t.integer  :activation_counter
      t.string   :status_message
      t.integer  :status_code
      t.integer  :customer_order_id
      t.references  :access, index: true
      t.integer  :direction
      t.string   :final_access_value
      t.string   :reason
      t.string   :ticket_code
      t.float    :credits
      t.float    :refundable_credits
      t.float    :final_balance
      t.float    :final_refundable_balance
      t.string   :initialization_type
      t.integer  :number_of_transactions
      t.references  :catalogable, polymorphic: true, index: true
      t.float    :items_amount
      t.float    :price
      t.string   :payment_method
      t.string   :payment_gateway
      t.timestamps null: false

      t.references  :profile
      t.references  :ticket
      t.integer :old_id
      t.float :credit_value
    end
  end
end
