class Jobs::Credential::OrderRedemptor < Jobs::Base
  TYPES = %w( order_redemption )

  def perform(transaction_id, _atts = {})
    ActiveRecord::Base.transaction do
      CredentialTransaction.find(transaction_id)
      # TODO: initialize_balance
      # TODO: generate_monetray_transaction
      # TODO: redeem_customer_order
    end
  end
end
