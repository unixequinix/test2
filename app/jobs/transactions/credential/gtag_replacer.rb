class Transactions::Credential::GtagReplacer < Transactions::Base
  include TransactionsHelper

  TRIGGERS = %w[gtag_replacement].freeze

  queue_as :medium_low

  def perform(atts)
    transaction = CredentialTransaction.find(atts[:transaction_id])
    new_gtag = transaction.gtag
    old_gtag = create_gtag(transaction.ticket_code, transaction.event_id)

    old_gtag.replace!(new_gtag)
  end
end
