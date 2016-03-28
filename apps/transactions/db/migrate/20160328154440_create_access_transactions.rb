class CreateAccessTransactions < ActiveRecord::Migration
  def change
    create_table :access_transactions do |t|
      t.references :event_id
      t.string :transaction_origin
      t.string :customer_tag_uid
      t.string :transaction_type
      t.references :operator_id
      t.references :station_id
      t.references :device_id
      t.string :device_db_index
      t.string :device_created_at
      t.references :customer_event_profile_id
      t.references :access_entitlement_id
      t.string :direcction
      t.string :final_balance
      t.string :status_code
      t.string :status_message
    end
  end
end
