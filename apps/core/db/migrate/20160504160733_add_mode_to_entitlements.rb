class AddModeToEntitlements < ActiveRecord::Migration
  def change
    add_column :entitlements, :mode, :string, default: "counter"
    Entitlement.where(infinite: true).update_all(mode: Entitlement::STRICT_PERMANENT)
  end
end
