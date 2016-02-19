class Jobs::Monetary::BalanceDecreaser < Jobs::Base
  def perform(transaction_id)
    t = MonetaryTransaction.find(transaction_id)

    ActiveRecord.transaction do
      # TODO: decrease_balance
    end
  end
end
