class Transactions::Credential::GtagChecker < Transactions::Credential::Base
  TRIGGERS = %w(gtag_checkin).freeze

  def perform(atts)
    Gtag.find(atts[:gtag_id]).update!(customer_id: atts[:customer_id])
  end
end
