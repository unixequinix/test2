class DestroyOldTables < ActiveRecord::Migration
  def change
    drop_table :entitlement_ticket_types
    drop_table :entitlements
    remove_reference :tickets, :ticket_type
    drop_table :ticket_types
    remove_reference :order_items, :online_product
    drop_table :online_products
  end
end
