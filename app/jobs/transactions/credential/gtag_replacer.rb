class Transactions::Credential::GtagReplacer < Transactions::Base
  include TransactionsHelper

  TRIGGERS = %w[gtag_replacement].freeze

  queue_as :low

  def perform(atts)
    new_gtag = Gtag.find_by(id: atts[:gtag_id], event_id: atts[:event_id])
    old_gtag = create_gtag(atts[:ticket_code], atts[:event_id])

    old_gtag.replace!(new_gtag)
  end
end
