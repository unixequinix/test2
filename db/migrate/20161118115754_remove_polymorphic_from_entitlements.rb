class RemovePolymorphicFromEntitlements < ActiveRecord::Migration
  def change
    rename_column :entitlements, :entitlementable_id, :access_id
    remove_column :entitlements, :entitlementable_type
  end
end
