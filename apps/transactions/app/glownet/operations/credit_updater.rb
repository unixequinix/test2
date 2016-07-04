class CreditUpdater < ActiveJob::Base
  def perform(credit_id, atts)
    credit = CustomerCredit.find(credit_id)
    credit.update! atts
  end
end
