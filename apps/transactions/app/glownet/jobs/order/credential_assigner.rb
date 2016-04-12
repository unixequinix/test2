class Jobs::Order::CredentialAssigner < Jobs::Base
  TRIGGERS = %w( record_purchase )

  def perform(atts)
    gtag = Event.find(atts[:event_id]).gtags.find_by_tag_uid(atts[:customer_tag_uid])
    return if gtag.assigned_gtag_credential
    id = atts[:customer_event_profile_id]
    gtag.create_assigned_gtag_credential!(customer_event_profile_id: id)
  end
end
