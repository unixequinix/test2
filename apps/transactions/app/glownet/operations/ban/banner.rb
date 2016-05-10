class Operations::Ban::Banner < Operations::Base
  TRIGGERS = %w( blacklist_gtag blacklist_ticket blacklist_customer ).freeze

  def perform(atts)
    event = Event.find(atts[:event_id])
    method_name = atts[:banneable_type].downcase.pluralize.to_sym
    obj = event.method(method_name).call.find(atts[:banneable_id])
    obj.update!(banned: true)
    return unless obj.is_a?(Profile)
    obj.credential_assignments.each { |cred| cred.credentiable.update!(banned: true) }
  end
end
