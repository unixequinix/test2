class RemoveEventCounters < ActiveRecord::Migration[5.1]
  def change
    remove_column :events, :device_registrations_count, :integer, default: 0
    remove_column :events, :devices_count, :integer, default: 0
    remove_column :events, :transactions_count, :integer, default: 0
    remove_column :events, :tickets_count, :integer, default: 0
    remove_column :events, :catalog_items_count, :integer, default: 0
    remove_column :events, :ticket_types_count, :integer, default: 0
    remove_column :events, :gtags_count, :integer, default: 0
    remove_column :events, :payment_gateways_count, :integer, default: 0
    remove_column :events, :stations_count, :integer, default: 0
    remove_column :events, :device_transactions_count, :integer, default: 0
    remove_column :events, :user_flags_count, :integer, default: 0
    remove_column :events, :accesses_count, :integer, default: 0
    remove_column :events, :operator_permissions_count, :integer, default: 0
    remove_column :events, :packs_count, :integer, default: 0
    remove_column :events, :customers_count, :integer, default: 0
    remove_column :events, :orders_count, :integer, default: 0
    remove_column :events, :refunds_count, :integer, default: 0
    remove_column :events, :event_registrations_count, :integer, default: 0
    remove_column :events, :users_count, :integer, default: 0
    remove_column :events, :stats_count, :integer, default: 0
    remove_column :events, :alerts_count, :integer, default: 0
    remove_column :events, :device_caches_count, :integer, default: 0
    remove_column :events, :pokes_count, :integer, default: 0
  end
end
