class AddExecutedToTransactions < ActiveRecord::Migration[5.0]
  def change
    add_column :transactions, :executed, :boolean
  end
end
