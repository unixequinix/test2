class AddColumnConstraintsToForeignKeys < ActiveRecord::Migration[5.1]
  def change
    change_column_null :access_control_gates, :access_id, false
    change_column_null :access_control_gates, :station_id, false

    change_column_null :catalog_items, :event_id, false

    change_column_null :companies, :event_id, false

    change_column_null :customers, :event_id, false

    change_column_null :device_registrations, :event_id, false
    change_column_null :device_registrations, :device_id, false

    DeviceTransaction.where(device_id: nil).delete_all
    change_column_null :device_transactions, :event_id, false
    change_column_null :device_transactions, :device_id, false

    change_column_null :event_registrations, :event_id, false
    change_column_null :event_registrations, :user_id, false


    change_column_null :order_items, :order_id, false
    change_column_null :order_items, :catalog_item_id, false

    change_column_null :orders, :customer_id, false
    change_column_null :orders, :event_id, false

    change_column_null :pack_catalog_items, :pack_id, false
    change_column_null :pack_catalog_items, :catalog_item_id, false

    change_column_null :payment_gateways, :event_id, false

    change_column_null :products, :event_id, false

    Refund.where(event_id: nil).delete_all
    change_column_null :refunds, :event_id, false
    change_column_null :refunds, :customer_id, false

    change_column_null :station_catalog_items, :catalog_item_id, false
    change_column_null :station_catalog_items, :station_id, false

    change_column_null :station_products, :product_id, false
    change_column_null :station_products, :station_id, false

    change_column_null :stations, :event_id, false

    change_column_null :ticket_types, :event_id, false

    change_column_null :tickets, :event_id, false
    change_column_null :tickets, :ticket_type_id, false

    change_column_null :topup_credits, :station_id, false
  end
end
