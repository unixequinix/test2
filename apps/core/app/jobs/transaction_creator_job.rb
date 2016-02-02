class TransactioncreatorJob < ActiveJob::Base
  queue_as :transactions

  def perform(atts)
    Transaction.write(atts)
  end
end