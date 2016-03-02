class Jobs::Money::CreditTransactionCreator < Jobs::Base
  def perform(atts)
    ActiveRecord::Base.transaction do
      atts[:transaction_category] = "credit"
      Jobs::Base.write(atts)
    end
  end
end
