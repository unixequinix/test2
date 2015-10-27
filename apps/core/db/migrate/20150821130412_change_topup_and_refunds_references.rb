class ChangeTopupAndRefundsReferences < ActiveRecord::Migration
  def change
    add_reference :orders, :customer_event_profile, index: true
    add_reference :claims, :customer_event_profile, index: true
    add_reference :credit_logs, :customer_event_profile, index: true
    remove_reference :orders, :customer, index: true
    remove_reference :claims, :customer, index: true
    remove_reference :credit_logs, :customer, index: true
  end
end