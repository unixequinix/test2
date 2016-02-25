class CustomerCreditHospitalityCreator < CustomerCreditCreator
  def initialize(attributes)
    super(attributes)
    @customer_credit.refundable_amount = 0
    @customer_credit.payment_method = "none"
  end
end
