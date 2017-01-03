class Transactions::Credential::GtagChecker < Transactions::Credential::Base
  TRIGGERS = %w(gtag_checkin).freeze

  def perform(atts)
    ActiveRecord::Base.transaction do
      gtag = Gtag.find_by(event_id: atts[:event_id], tag_uid: atts[:customer_tag_uid])
      gtag.update!(customer_id: atts[:customer_id])
    end
  end
end
