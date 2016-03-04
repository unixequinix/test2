class CreateCreditTransactions < ActiveRecord::Migration
  # rubocop:disable Metrics/MethodLength
  def change
    create_table :credit_transactions do |t|
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
      t.float :credits
      t.float :credits_refundable
      t.float :credit_value
      t.float :final_balance
      t.float :final_refundable_balance
      t.references :customer_event_profile, index: true, foreign_key: true
      t.integer :status_code
      t.string :status_message
    end
  end
end
