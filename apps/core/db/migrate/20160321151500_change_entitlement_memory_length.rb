class ChangeEntitlementMemoryLength < ActiveRecord::Migration
  def change
    add_column :entitlements, :memory_length_aux, :integer, default: 1
    Entitlement.all.each do |entitlement|
      binding.pry
      entitlement.update_attribute(:memory_length_aux, 1) if entitlement.memory_length == "simple"
      entitlement.update_attribute(:memory_length_aux, 2) if entitlement.memory_length == "double"
    end
    remove_column :entitlements, :memory_length
    rename_column :entitlements, :memory_length_aux, :memory_length
  end
end
