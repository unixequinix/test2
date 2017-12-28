class AddDefaultToTransactionPaymets < ActiveRecord::Migration[5.1]
  def change
    change_column_default :transactions, :payments_summary, to: [], from: nil
    change_column_default :sale_items, :payments, to: [], from: nil
  end
end
