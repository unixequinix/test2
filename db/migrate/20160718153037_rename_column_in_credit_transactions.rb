class RenameColumnInCreditTransactions < ActiveRecord::Migration
  def change
    rename_column :credit_transactions, :credits_refundable, :refundable_credits
  end
end
