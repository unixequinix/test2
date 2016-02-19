class Jobs::Credential::OrderCreator < Jobs::Base
  TYPES = []

  def perform(transaction_id)
    t = CredentialTransaction.find(transaction_id)
    t.inspect

    ActiveRecord::Base.transaction do
      # TODO: create_customer_order
      # TODO: Marked as redeemed customer order in case was created
    end
  end
end
