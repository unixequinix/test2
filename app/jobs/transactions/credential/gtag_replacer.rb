class Transactions::Credential::GtagReplacer < Transactions::Base
  TRIGGERS = %w[gtag_replacement].freeze

  def perform(atts)
    event = Event.find(atts[:event_id])
    new_gtag = event.gtags.find(atts[:gtag_id])
    old_gtag = create_gtag(atts[:ticket_code], event.id)
    old_gtag.update!(active: false, banned: true)

    # the old_gtag might have a registered customer or at the very least the one we just created, also orders...
    # the new one is anonymous.
    Customer.claim(event, old_gtag.customer_id, new_gtag.customer_id)
    new_gtag.update!(active: true)
  end
end
