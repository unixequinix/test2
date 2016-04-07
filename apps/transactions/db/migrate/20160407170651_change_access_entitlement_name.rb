class ChangeAccessEntitlementName < ActiveRecord::Migration
  def change
    rename_column :access_transactions, :access_entitlement_id, :access_id
  end
end
