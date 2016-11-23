class AddForeignKeys < ActiveRecord::Migration
  def change
    Customer.where(event_id: 0).update_all(event_id: 5)
    Ticket.where(company_ticket_type_id: 150).destroy_all
    Transaction.where(station_id: 817).destroy_all

    add_foreign_key :catalog_items, :events
    add_foreign_key :company_event_agreements, :companies
    add_foreign_key :company_event_agreements, :events
    add_foreign_key :company_ticket_types, :events
    add_foreign_key :company_ticket_types, :company_event_agreements
    add_foreign_key :company_ticket_types, :credential_types
    add_foreign_key :customers, :events
    add_foreign_key :entitlements, :events
    add_foreign_key :event_translations, :events
    add_foreign_key :gtags, :events
    add_foreign_key :order_items, :orders
    add_foreign_key :order_items, :catalog_items
    add_foreign_key :pack_catalog_items, :catalog_items
    add_foreign_key :products, :events
    add_foreign_key :sale_items, :products
    add_foreign_key :station_catalog_items, :catalog_items
    add_foreign_key :station_products, :products
    add_foreign_key :stations, :events
    add_foreign_key :tickets, :events

    all_types = ActiveRecord::Base.connection.execute("SELECT company_ticket_type_id, id FROM tickets;").column_values(0).uniq.map(&:to_i)
    all_tickets = Ticket.unscoped.uniq.pluck(:company_ticket_type_id)
    Ticket.where(company_ticket_type_id: all_tickets - all_types).destroy_all

    add_foreign_key :tickets, :company_ticket_types
    add_foreign_key :transactions, :catalog_items
    add_foreign_key :transactions, :orders
    add_foreign_key :transactions, :gtags
    add_foreign_key :transactions, :customers
    add_foreign_key :transactions, :events
    add_foreign_key :transactions, :stations
  end
end
