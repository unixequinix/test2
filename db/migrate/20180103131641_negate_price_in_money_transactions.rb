class NegatePriceInMoneyTransactions < ActiveRecord::Migration[5.1]
  def change
    Transaction.find_by_sql("UPDATE transactions SET price = -price WHERE type IN ('MoneyTransaction') AND action = 'online_refund' AND price > 0")
  end
end
