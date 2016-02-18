class MonetaryTransactionOnlineCreator < MonetaryTransaction
  def initialize(attributes)
    super(attributes)
    refundable_amount = attributes[:amount] -
                        @monetary_transaction.credit_value *
                        attributes[:credits]
    @monetary_transaction.refundable_amount = refundable_amount
    @monetary_transaction.transaction_source = "online"
  end
end
