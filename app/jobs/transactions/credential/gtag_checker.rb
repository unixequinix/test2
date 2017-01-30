class Transactions::Credential::GtagChecker < Transactions::Base
  TRIGGERS = %w(gtag_checkin record_purchase).freeze

  def perform(atts)
    gtag = if atts[:gtag_id]
             Gtag.find(atts[:gtag_id])
           else
             Event.find(atts[:event_id]).gtags.find_by(tag_uid: atts[:customer_tag_uid])
           end
    Transaction.find(atts[:transaction_id]).update!(gtag: gtag) unless atts[:gtag_id]
    gtag.update!(customer_id: atts[:customer_id])
  end
end