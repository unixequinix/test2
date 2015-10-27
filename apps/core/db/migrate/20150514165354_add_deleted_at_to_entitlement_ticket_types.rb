class AddDeletedAtToEntitlementTicketTypes < ActiveRecord::Migration
  def change
    add_column :entitlement_ticket_types, :deleted_at, :datetime
    add_index :entitlement_ticket_types, :deleted_at
  end
end
