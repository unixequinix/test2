class RenameBlacklistToBan < ActiveRecord::Migration
  def change
    rename_column :tickets, :blacklist, :banned
    rename_column :gtags, :blacklist, :banned
    rename_column :profiles, :blacklist, :banned
    rename_column :blacklist_transactions, :blacklisted_id, :banneable_id
    rename_column :blacklist_transactions, :blacklisted_type, :banneable_type
    rename_table :blacklist_transactions, :ban_transactions
  end
end
