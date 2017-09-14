class AddDefaultToOtherAmountInTransactions < ActiveRecord::Migration[5.1]
  def change
    Transaction.where(other_amount_credits: nil).update_all(other_amount_credits: 0)

    change_column_null :transactions, :other_amount_credits, false
    change_column_default :transactions, :other_amount_credits, 0
  end
end
