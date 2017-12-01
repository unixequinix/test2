class Transactions::Credential::GtagChecker < Transactions::Base
  TRIGGERS = %w[gtag_checkin].freeze

  queue_as :medium_low

  def perform(atts)
    t = CredentialTransaction.find(atts[:transaction_id])
    gtag = t.gtag
    gtag.redeemed? ? Alert.propagate(t.event, gtag, "has been redeemed twice") : gtag.update!(redeemed: true)
  end
end
