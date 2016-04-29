class RenameCustomerEventProfiles < ActiveRecord::Migration
  def change
    rename_column :access_transactions, :customer_event_profile_id, :profile_id
    rename_column :money_transactions, :customer_event_profile_id, :profile_id
    rename_column :credit_transactions, :customer_event_profile_id, :profile_id
    rename_column :order_transactions, :customer_event_profile_id, :profile_id
    rename_column :credential_transactions, :customer_event_profile_id, :profile_id
    rename_column :blacklist_transactions, :customer_event_profile, :profile_id
    rename_column :orders, :customer_event_profile_id, :profile_id
    rename_column :customer_orders, :customer_event_profile_id, :profile_id
    rename_column :customer_credits, :customer_event_profile_id, :profile_id
    rename_column :payment_gateway_customers, :customer_event_profile_id, :profile_id
    rename_column :credential_assignments, :customer_event_profile_id, :profile_id
    rename_column :claims, :customer_event_profile_id, :profile_id

    rename_table :customer_event_profiles, :profiles
  end
end
