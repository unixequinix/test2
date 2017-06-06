class Transactions::Credential::GtagReplacer < Transactions::Base
  TRIGGERS = %w[gtag_replacement].freeze

  def perform(atts)
    event = Event.find(atts[:event_id])
    new_gtag = event.gtags.find(atts[:gtag_id])

    begin
      old_gtag = Gtag.find_or_create_by(tag_uid: atts[:ticket_code], event_id: event.id)
    rescue ActiveRecord::RecordNotUnique
      retry
    end

    customer = old_gtag.customer
    old_gtag.update!(active: false, banned: true)
    new_gtag.update!(customer: customer, active: true)
  end
end
