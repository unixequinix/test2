class Jobs::Monetary::BalanceIncreaser < Jobs::Base
  TYPES = %w( topup sale_refund  )

  def perform(transaction_id, _atts = {})
    ActiveRecord::Base.transaction do
      MoneyTransaction.find(transaction_id)
      # TODO: increase_balance
    end
  end
end
