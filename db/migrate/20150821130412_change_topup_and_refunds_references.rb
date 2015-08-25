class ChangeTopupAndRefundsReferences < ActiveRecord::Migration
  def change
    rename_column :orders, :customer_id, :customer_event_profile_id
    rename_column :claims, :customer_id, :customer_event_profile_id
    rename_column :credit_logs, :customer_id, :customer_event_profile_id
  end
end