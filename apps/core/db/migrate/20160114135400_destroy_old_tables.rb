class DestroyOldTables < ActiveRecord::Migration
  def change
    drop_table :entitlement_ticket_types
    drop_table :entitlements
    #drop_table :ticket_types
  end
end