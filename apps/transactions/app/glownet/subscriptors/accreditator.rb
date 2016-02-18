class Accreditator

  def perform
    ActiveRecord.transaction do
      gtag = Gtag.find_by(event: event, tag_uid: customer_tag_uid)
      gtag.credential_assignments.create!(event: event, customer_event_profile: profile)
      profile = customer_event_profile.create!(event: event)
      # TODO: create_customer_order
      # TODO: redeem_customer_order
    end
  end
end