class RenamePaymentsInTransactions < ActiveRecord::Migration[5.1]
  def change
    rename_column :transactions, :payments_summary, :payments
  end
end
