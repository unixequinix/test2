class Profile::Checker
  def self.for_transaction(atts)
    gtag = Event.find(atts[:event_id]).gtags.find_by(tag_uid: atts[:customer_tag_uid])
    tag_profile = gtag&.assigned_customer_event_profile&.id
    trans_profile = atts[:customer_event_profile_id]
    fail "Profile Fraud detected" if trans_profile.present? && tag_profile != trans_profile
    return tag_profile if tag_profile
    CustomerEventProfile.create!(event_id: atts[:event_id]).id
  end

  def self.for_credentiable(obj, customer)
    profile = obj.assigned_customer_event_profile
    return customer.create_customer_event_profile!(event: obj.event) unless profile
    fail "Credentiable Fraud detected" if profile.customer
    customer.update!(customer_event_profile: profile)
  end
end
