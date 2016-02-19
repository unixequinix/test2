class Jobs::Monetary::BalanceDecreaser < Jobs::Base
  TYPES = %w( fee refund sale  )

  def perform(transaction_id)
    t = MonetaryTransaction.find(transaction_id)
    t.inspect

    ActiveRecord::Base.transaction do
      # TODO: decrease_balance
    end
  end
end
