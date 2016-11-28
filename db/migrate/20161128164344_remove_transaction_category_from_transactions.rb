class RemoveTransactionCategoryFromTransactions < ActiveRecord::Migration
  def change
    remove_column :transactions, :transaction_category, :string
  end
end
