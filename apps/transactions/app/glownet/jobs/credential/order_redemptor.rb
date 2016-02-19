class Jobs::Credential::OrderRedemptor < Jobs::Base
  TYPES = %w( order_redemption )

  def perform(transaction_id)
    t = CredentialTransaction.find(transaction_id)
    t.inspect

    ActiveRecord::Base.transaction do
      # TODO: initialize_balance
      # TODO: generate_monetray_transaction
      # TODO: redeem_customer_order
    end
  end
end
