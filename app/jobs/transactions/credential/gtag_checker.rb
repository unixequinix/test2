class Transactions::Credential::GtagChecker < Transactions::Base
  TRIGGERS = %w[gtag_checkin].freeze

  queue_as :medium_low

  def perform(atts)
    gtag = Gtag.find(atts[:gtag_id])
    gtag.redeemed? ? Alert.propagate(Event.find(atts[:event_id]), gtag, "has been redeemed twice") : gtag.update!(redeemed: true)
  end
end
