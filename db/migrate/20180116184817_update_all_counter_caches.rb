class UpdateAllCounterCaches < ActiveRecord::Migration[5.1]
  def change
    Event.find_each do |event|
      Event.reset_counters(event.id, :device_registrations)
      Event.reset_counters(event.id, :devices)
      Event.reset_counters(event.id, :tickets)
      Event.reset_counters(event.id, :catalog_items)
      Event.reset_counters(event.id, :ticket_types)
      Event.reset_counters(event.id, :companies)
      Event.reset_counters(event.id, :gtags)
      Event.reset_counters(event.id, :stations)
      Event.reset_counters(event.id, :device_transactions)
      Event.reset_counters(event.id, :user_flags)
      Event.reset_counters(event.id, :accesses)
      Event.reset_counters(event.id, :operator_permissions)
      Event.reset_counters(event.id, :packs)
      Event.reset_counters(event.id, :customers)
      Event.reset_counters(event.id, :orders)
      Event.reset_counters(event.id, :refunds)
      Event.reset_counters(event.id, :event_registrations)
      Event.reset_counters(event.id, :users)
      Event.reset_counters(event.id, :alerts)
      Event.reset_counters(event.id, :device_caches)
      Event.reset_counters(event.id, :pokes)
    end
  end
end
