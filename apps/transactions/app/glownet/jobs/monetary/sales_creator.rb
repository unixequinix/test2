class Jobs::Monetary::SalesCreator < Jobs::Base
  TYPES = %w( sale )

  def perform(transaction_id, _atts = {})
    ActiveRecord::Base.transaction do
      MoneyTransaction.find(transaction_id)
      # TODO: increase_balance
    end
  end
end
