class CustomerCreditOnlineCreator < CustomerCreditCreator
  def initialize(attributes)
    super(attributes)
    refundable_amount = attributes[:amount] - @customer_credit.credit_value * attributes[:credits]
    @customer_credit.refundable_amount = refundable_amount
    @customer_credit.transaction_source = "online"
  end
end
