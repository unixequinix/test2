class RenameCredentialRedeemedInTicket < ActiveRecord::Migration
  def change
    rename_column(:tickets, :credential_redeemed, :redeemed) if column_exists?(:tickets, :credential_redeemed)
  end
end
