class EditOrderTransactions < ActiveRecord::Migration
  def change # rubocop:disable Metrics/MethodLength
    drop_table :order_transactions
    create_table :order_transactions, force: :cascade do |t|
      t.references :event, index: true, foreign_key: true
      t.string :transaction_origin
      t.string :transaction_category
      t.string :transaction_type
      t.string :customer_tag_uid
      t.string :operator_tag_uid
      t.references :station, index: true, foreign_key: true
      t.string :device_uid
      t.integer :device_db_index
      t.string :device_created_at
      t.references :customer_order, index: true, foreign_key: true
      t.references :catalog_item, index: true, foreign_key: true
      t.references :customer_event_profile, index: true, foreign_key: true
      t.string :integer
      t.string :status_message
    end
  end
end
