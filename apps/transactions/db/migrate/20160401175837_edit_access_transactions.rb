class EditAccessTransactions < ActiveRecord::Migration
  def change
    drop_table :access_transactions
    create_table "access_transactions", force: :cascade do |t|
      t.references :event, index: true, foreign_key: true
      t.string :transaction_origin
      t.string :customer_tag_uid
      t.string :transaction_type
      t.references :operator, index: true, foreign_key: false
      t.references :station, index: true, foreign_key: true
      t.references :device, index: true, foreign_key: false
      t.integer :device_db_index
      t.string :device_created_at
      t.references :customer_event_profile, index: true, foreign_key: true
      t.references :access_entitlement, index: true, foreign_key: false
      t.integer :direction
      t.string :final_balance
      t.integer :status_code
      t.string :status_message
    end
  end
end
