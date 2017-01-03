class Transactions::Order::CredentialAssigner < Transactions::Base
  TRIGGERS = %w(record_purchase).freeze

  def perform(atts)
    gtag = Gtag.find_by(tag_uid: atts[:customer_tag_uid], event_id: atts[:event_id])
    return if gtag.customer
    gtag.update!(customer_id: atts[:customer_id])
  end
end
