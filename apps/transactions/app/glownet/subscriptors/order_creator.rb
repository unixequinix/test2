class OrderCreator

  def perform
    ActiveRecord.transaction do
      # TODO: initialize_balance
      # TODO: generate_monetray_transaction
      # TODO: redeem_customer_order
    end
  end
end