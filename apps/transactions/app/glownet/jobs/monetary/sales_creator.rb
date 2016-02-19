class Jobs::Monetary::SalesCreator < Jobs::Base
  def perform(transaction_id)
    t = MonetaryTransaction.find(transaction_id)

    ActiveRecord.transaction do
      # TODO: increase_balance
    end
  end
end
