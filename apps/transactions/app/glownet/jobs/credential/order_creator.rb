class Jobs::Credential::OrderCreator < Jobs::Base
  TYPES = []

  def perform(transaction_id, _atts = {})
    ActiveRecord::Base.transaction do
      CredentialTransaction.find(transaction_id)
      # TODO: create_customer_order
      # TODO: Marked as redeemed customer order in case was created
    end
  end
end
