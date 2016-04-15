class Operations::Credential::GtagChecker < Operations::Credential::Base
  TRIGGERS = %w( gtag_checkin )

  def perform(atts)
    ActiveRecord::Base.transaction do
      gtag = Gtag.find_by(event_id: atts[:event_id], tag_uid: atts[:customer_tag_uid])
      assign_gtag_credential(gtag, atts[:customer_event_profile_id])
      mark_redeemed(gtag)
    end
  end
end
