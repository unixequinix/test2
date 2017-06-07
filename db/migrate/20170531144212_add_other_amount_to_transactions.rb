class AddOtherAmountToTransactions < ActiveRecord::Migration[5.1]
  def change
    add_column :transactions, :other_amount_credits, :float
  end
end
