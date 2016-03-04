class RenameTransactionSourceInCustomerCredits < ActiveRecord::Migration
  def change
    rename_column :customer_credits, :transaction_source, :transaction_origin
  end
end
