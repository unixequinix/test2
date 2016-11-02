class DeleteInfiniteInEntitlements < ActiveRecord::Migration
  def change
    remove_column :entitlements, :infinite
  end
end
