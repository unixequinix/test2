class MonetaryTransactionHospitalityCreator < MonetaryTransaction
  def initialize(attributes)
    super(attributes)
    @monetary_transaction.refundable_amount = 0
    @monetary_transaction.payment_method = "none"
  end
end
