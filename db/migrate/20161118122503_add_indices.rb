class AddIndices < ActiveRecord::Migration
  def change
    add_index :access_control_gates, :access_id
    add_index :company_event_agreements, :company_id
    add_index :company_event_agreements, :event_id
    add_index :company_ticket_types, :event_id
    add_index :company_ticket_types, :company_event_agreement_id
    add_index :company_ticket_types, :credential_type_id
    add_index :credential_types, :catalog_item_id
    add_index :customers, :event_id
    add_index :entitlements, :event_id
    add_index :entitlements, :access_id
    add_index :event_translations, :event_id
    add_index :gtags, :event_id
    add_index :order_items, :order_id
    add_index :order_items, :catalog_item_id
    add_index :pack_catalog_items, :pack_id
    add_index :products, :event_id
    add_index :sale_items, :credit_transaction_id
    add_index :sale_items, :product_id
    add_index :station_catalog_items, :catalog_item_id
    add_index :station_products, :product_id
    add_index :stations, :event_id
    add_index :stations, :station_event_id
    add_index :tickets, :event_id
    add_index :tickets, :company_ticket_type_id
    add_index :topup_credits, :credit_id
    add_index :transactions, :access_id
    add_index :transactions, :catalog_item_id
    add_index :transactions, :operator_station_id
    add_index :transactions, :order_id
    add_index :transactions, :gtag_id
    add_index :transactions, :customer_id
  end
end
