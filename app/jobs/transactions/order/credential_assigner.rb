class Transactions::Order::CredentialAssigner < Transactions::Base
  TRIGGERS = %w( record_purchase ).freeze

  def perform(atts)
    gtag = Gtag.find_by(tag_uid: atts[:customer_tag_uid], event_id: atts[:event_id])
    return if gtag.profile
    gtag.update!(profile_id: atts[:profile_id])
  end
end
