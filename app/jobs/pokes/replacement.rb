class Pokes::Replacement < Pokes::Base
  include PokesHelper
  include TransactionsHelper

  TRIGGERS = %w[gtag_replacement].freeze

  def perform(transaction)
    old_gtag = create_gtag(transaction.ticket_code, transaction.event_id)
    old_gtag.replace!(transaction.gtag)
    transaction.update! customer: transaction.gtag.customer

    create_poke(extract_atts(transaction, extract_credential_info(old_gtag, action: "replacement", description: "gtag")))
  end
end
