class Pokes::Replacement < Pokes::Base
  include PokesHelper
  include TransactionsHelper

  TRIGGERS = %w[gtag_replacement].freeze

  def perform(t)
    old_gtag = create_gtag(t.ticket_code, t.event_id)
    old_gtag.replace!(t.gtag)

    create_poke(extract_atts(t, extract_credential_info(old_gtag, action: "replacement", description: "gtag")))
  end
end
