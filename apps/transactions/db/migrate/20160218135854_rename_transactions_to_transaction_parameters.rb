class RenameTransactionsToTransactionParameters < ActiveRecord::Migration
  def change
    rename_table :transactions, :transaction_parameters
    rename_column :monetary_transactions, :transaction_id, :transaction_parameter_id
    rename_column :credential_transactions, :transaction_id, :transaction_parameter_id
    rename_column :access_transactions, :transaction_id, :transaction_parameter_id
  end
end
