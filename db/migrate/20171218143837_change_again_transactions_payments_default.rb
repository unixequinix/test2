class ChangeAgainTransactionsPaymentsDefault < ActiveRecord::Migration[5.1]
  def change
    change_column_default :transactions, :payments, to: {}, from: []
    change_column_default :sale_items, :payments, to: {}, from: []
  end
end
