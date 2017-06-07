class Transactions::Credential::GtagChecker < Transactions::Base
  TRIGGERS = %w[gtag_checkin].freeze

  def perform(atts)
    gtag = Gtag.find(atts[:gtag_id])
    gtag.redeemed? ? Alert.propagate(event, "has been redeemed twice", :high, gtag) : gtag.update!(redeemed: true)
  end
end
