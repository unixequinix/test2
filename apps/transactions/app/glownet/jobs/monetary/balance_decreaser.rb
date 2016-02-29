class Jobs::Monetary::BalanceDecreaser < Jobs::Base
  TYPES = %w( fee refund sale  )

  def perform(transaction_id, _atts = {})
    ActiveRecord::Base.transaction do
      MoneyTransaction.find(transaction_id)
      # TODO: decrease_balance
    end
  end
end
