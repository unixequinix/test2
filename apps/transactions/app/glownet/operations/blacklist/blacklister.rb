class Operations::Blacklist::Blacklister < Operations::Base
  TRIGGERS = %w( blacklist_gtag blacklist_ticket blacklist_customer )

  def perform(atts)
    event = Event.find(atts[:event_id])
    method_name = atts[:blacklisted_type].downcase.pluralize.to_sym
    obj = event.method(method_name).call.find(atts[:blacklisted_id])
    obj.update!(blacklist: true)
    return unless obj.is_a?(Profile)
    obj.credential_assignments.each { |cred| cred.credentiable.update!(blacklist: true) }
  end
end
