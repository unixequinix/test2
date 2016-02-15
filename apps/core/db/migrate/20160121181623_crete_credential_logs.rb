class CreteCredentialLogs < ActiveRecord::Migration
  # rubocop:disable Metrics/MethodLength
  def change
    create_table :stations do |t|
      t.timestamps null: false
    end

    create_table :devices do |t|
      t.timestamps null: false
    end

    create_table :event_logs do |t|
      t.string :type, null: false
      t.references :event
      t.string :transaction_type
      t.timestamp :device_created_at
      t.references :ticket
      t.string :customer_tag_uid
      t.string :operator_tag_uid
      t.references :station
      t.references :device
      t.integer :device_uid
      t.references :preevent_product
      t.references :customer_event_profile
      t.string :payment_method
      t.float :amount, default: 0.00
      t.string :status_code
      t.string :status_message
      t.timestamps null: false
    end
  end
end
