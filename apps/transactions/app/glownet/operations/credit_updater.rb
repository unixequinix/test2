class Credit < ActiveJob::Base
  def perform(credit_id, counter, date)
    credit = CustomerCredit.find(credit_id)
    credit.update! gtag_counter: counter, created_in_origin_at: date
  end
end