class Operations::Order::CredentialAssigner < Operations::Base
  TRIGGERS = %w( record_purchase ).freeze

  def perform(atts)
    gtag = Gtag.find_by(tag_uid: atts[:customer_tag_uid], event_id: atts[:event_id])
    return if gtag.assigned_gtag_credential
    id = atts[:profile_id]
    gtag.create_assigned_gtag_credential!(profile_id: id)
  end
end
