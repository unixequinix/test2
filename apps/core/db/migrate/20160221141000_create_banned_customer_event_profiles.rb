class CreateBannedCustomerEventProfiles < ActiveRecord::Migration
  def change
    create_table :banned_customer_event_profiles do |t|
      t.references :customer_event_profile

      t.datetime :deleted_at, index: true
      t.timestamps null: false
    end
  end
end