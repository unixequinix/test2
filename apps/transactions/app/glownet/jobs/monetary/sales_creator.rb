class Jobs::Monetary::SalesCreator < Jobs::Base
  TYPES = %w( sale  )

  def perform(transaction_id)
    t = MonetaryTransaction.find(transaction_id)
    t.inspect

    ActiveRecord::Base.transaction do
      # TODO: increase_balance
    end
  end
end
