class CustomerCreditOnlineCreator < CustomerCreditCreator
  def initialize(attributes)
    super(attributes)
    refundable_amount = attributes[:amount] -
                        credit_value(attributes[:customer_event_profile].event) *
                        attributes[:money_payed]
    @customer_credit.refundable_amount = refundable_amount
    @customer_credit.transaction_source = "online"
  end
end
