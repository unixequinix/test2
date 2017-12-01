module Transactions
  class Credential::GtagChecker < Transactions::Base
    TRIGGERS = %w[gtag_checkin].freeze

    queue_as :medium_low

    def perform(transaction, _atts = {})
      gtag = transaction.gtag
      gtag.redeemed? ? Alert.propagate(transaction.event, gtag, "has been redeemed twice") : gtag.update!(redeemed: true)
    end
  end
end
