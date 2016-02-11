class TransactionCreatorJob < ActiveJob::Base
  queue_as :transactions

  def perform(atts)
    Transaction.write(atts.delete(:transaction_category), atts)
  end
end
