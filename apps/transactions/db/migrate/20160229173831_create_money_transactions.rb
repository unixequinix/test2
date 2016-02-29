class CreateMoneyTransactions < ActiveRecord::Migration
  def change
    create_table :money_transactions do |t|
      t.references :event, index: true, foreign_key: true
      t.string :transaction_origin
      t.string :transaction_category
      t.string :transaction_type
      t.string :customer_tag_uid
      t.string :operator_tag_uid
      t.references :station, index: true, foreign_key: true
      t.string :device_uid
      t.integer :device_db_index
      t.timestamp :device_created_at
      t.integer :catalogable_id, foreign_key: false
      t.string :catalogable_type
      t.integer :items_amount
      t.float :price
      t.string :payment_method
      t.string :payment_gateway
      t.references :customer_event_profile, index: true, foreign_key: true
      t.integer :status_code
      t.string :status_message
    end
  end
end
