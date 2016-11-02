class CreateOrderTransactions < ActiveRecord::Migration
  def change # rubocop:disable Metrics/MethodLength
    create_table :order_transactions do |t|
      t.references :event_id
      t.string :transaction_origin
      t.string :transaction_category
      t.string :transaction_type
      t.string :customer_tag_uid
      t.string :operator_tag_uid
      t.references :station_id
      t.string :device_uid
      t.integer :device_db_index
      t.string :device_created_at
      t.references :customer_order_id
      t.references :catalog_item_id
      t.references :customer_event_profile_id
      t.string :integer
      t.string :status_message
    end
  end
end
