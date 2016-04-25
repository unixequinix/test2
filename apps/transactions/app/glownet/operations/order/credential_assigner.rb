class Operations::Order::CredentialAssigner < Operations::Base
  TRIGGERS = %w( record_purchase )

  def perform(atts)
    gtag = Gtag.find_by(tag_uid: atts[:customer_tag_uid], event_id: atts[:event_id])
    return if gtag.assigned_gtag_credential
    id = atts[:customer_event_profile_id]
    gtag.create_assigned_gtag_credential!(customer_event_profile_id: id)
  end
end
