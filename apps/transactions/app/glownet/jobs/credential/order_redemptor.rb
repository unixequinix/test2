class Jobs::Credential::OrderRedemptor < Jobs::Base
  def perform
    ActiveRecord.transaction do
      # TODO: create_customer_order
      # TODO: redeem_customer_order
    end
  end
end
