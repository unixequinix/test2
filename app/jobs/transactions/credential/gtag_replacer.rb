module Transactions
  class Credential::GtagReplacer < Transactions::Base
    include TransactionsHelper

    TRIGGERS = %w[gtag_replacement].freeze

    queue_as :medium_low

    def perform(transaction, _atts = {})
      new_gtag = transaction.gtag
      old_gtag = create_gtag(transaction.ticket_code, transaction.event_id)

      old_gtag.replace!(new_gtag)
    end
  end
end
