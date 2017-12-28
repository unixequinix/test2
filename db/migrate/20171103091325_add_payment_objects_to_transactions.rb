class AddPaymentObjectsToTransactions < ActiveRecord::Migration[5.1]
  def change
    add_column :transactions, :payments_summary, :jsonb
    add_column :sale_items, :payments, :jsonb
  end
end
