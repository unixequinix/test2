class AddDeletedAtToEntitlements < ActiveRecord::Migration
  def change
    add_column :entitlements, :deleted_at, :datetime
    add_index :entitlements, :deleted_at
  end
end
