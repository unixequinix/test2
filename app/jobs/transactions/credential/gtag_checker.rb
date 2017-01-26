class Transactions::Credential::GtagChecker < Transactions::Base
  TRIGGERS = %w(gtag_checkin record_purchase).freeze

  def perform(atts)
    Gtag.find(atts[:gtag_id]).update!(customer_id: atts[:customer_id])
  end
end
