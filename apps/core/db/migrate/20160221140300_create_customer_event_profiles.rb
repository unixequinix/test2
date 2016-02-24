class CreateCustomerEventProfiles < ActiveRecord::Migration
  def change
    create_table :customer_event_profiles do |t|
      t.references :customer
      t.references :event, null: false

      t.datetime :deleted_at, index: true
      t.timestamps null: false
  end
end
