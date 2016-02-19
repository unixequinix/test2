class Jobs::Monetary::BalanceIncreaser < Jobs::Base
  TYPES = %w( topup sale_refund  )

  def perform(transaction_id)
    t = MonetaryTransaction.find(transaction_id)
    t.inspect

    ActiveRecord::Base.transaction do
      # TODO: increase_balance
    end
  end
end
