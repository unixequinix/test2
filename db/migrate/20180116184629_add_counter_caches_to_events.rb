class AddCounterCachesToEvents < ActiveRecord::Migration[5.1]
  def change
    add_column :events, :device_registrations_count, :integer, default: 0
    add_column :events, :devices_count, :integer, default: 0
    add_column :events, :transactions_count, :integer, default: 0
    add_column :events, :tickets_count, :integer, default: 0
    add_column :events, :catalog_items_count, :integer, default: 0
    add_column :events, :ticket_types_count, :integer, default: 0
    add_column :events, :companies_count, :integer, default: 0
    add_column :events, :gtags_count, :integer, default: 0
    add_column :events, :payment_gateways_count, :integer, default: 0
    add_column :events, :stations_count, :integer, default: 0
    add_column :events, :device_transactions_count, :integer, default: 0
    add_column :events, :user_flags_count, :integer, default: 0
    add_column :events, :accesses_count, :integer, default: 0
    add_column :events, :operator_permissions_count, :integer, default: 0
    add_column :events, :packs_count, :integer, default: 0
    add_column :events, :customers_count, :integer, default: 0
    add_column :events, :orders_count, :integer, default: 0
    add_column :events, :refunds_count, :integer, default: 0
    add_column :events, :event_registrations_count, :integer, default: 0
    add_column :events, :users_count, :integer, default: 0
    add_column :events, :stats_count, :integer, default: 0
    add_column :events, :alerts_count, :integer, default: 0
    add_column :events, :device_caches_count, :integer, default: 0
    add_column :events, :pokes_count, :integer, default: 0
  end
end
