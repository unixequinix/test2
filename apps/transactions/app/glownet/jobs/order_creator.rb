class Jobs::OrderCreator < ActiveJob::Base
  def perform(transaction_id)
    t = CredentialTransaction.find(transaction_id)

    ActiveRecord.transaction do
      # TODO: initialize_balance
      # TODO: generate_monetray_transaction
      # TODO: redeem_customer_order
    end
  end
end
