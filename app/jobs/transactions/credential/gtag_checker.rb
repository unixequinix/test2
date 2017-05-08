class Transactions::Credential::GtagChecker < Transactions::Base
  TRIGGERS = %w[gtag_checkin].freeze

  def perform(atts)
    Gtag.find(atts[:gtag_id]).update!(redeemed: true)
  end
end
