class Transactions::Credential::GtagReplacer < Transactions::Base
  TRIGGERS = %w[gtag_replacement].freeze

  def perform(atts)
    event = Event.find(atts[:event_id])
    new_gtag = event.gtags.find(atts[:gtag_id])

    old_gtag = create_gtag(tag_uid: atts[:ticket_code], event_id: event.id)
    old_gtag.update!(active: false, banned: true)

    message = "is already associated with a customer, but it is the replacement of #{old_gtag.tag_uid}"
    Alert.propagate(event, message, :high, new_gtag) && return if new_gtag.customer_not_anonymous?

    new_gtag.customer&.destroy
    new_gtag.update!(customer: old_gtag.customer, active: true)
  end
end
