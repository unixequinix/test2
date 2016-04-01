class Jobs::Order::CredentialAssigner < Jobs::Base
  SUBSCRIPTIONS = %w( record_purchase )

  def perform(atts)
    gtag = Gtag.find_by_tag_uid(atts[:customer_tag_uid])
    profile = CustomerEventProfile.find(atts[:customer_event_profile_id])
    return if gtag.assigned_gtag_credential
    gtag.create_assigned_gtag_credential!(customer_event_profile: profile)
  end
end
