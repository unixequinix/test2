class Profile::Checker
  def self.for_transaction(atts)
    gtag = Event.find(atts[:event_id]).gtags.find_by(tag_uid: atts[:customer_tag_uid])
    tag_profile = gtag&.assigned_customer_event_profile&.id
    trans_profile = atts[:customer_event_profile_id]
    fail "Profile Fraud detected" if trans_profile.present? && tag_profile != trans_profile
    return tag_profile if tag_profile
    profile = CustomerEventProfile.create!(event_id: atts[:event_id])
    profile.gtag_assignment.create(credentiable: gtag)
    profile.id
  end

  def self.for_credentiable(obj, customer)
    cred_profile = obj.assigned_customer_event_profile
    cust_profile = customer.customer_event_profile

    fail "Credentiable Fraud detected" if cred_profile&.customer

    unless cred_profile
      cust_profile ||= customer.create_customer_event_profile!(event: obj.event)
      obj.credential_assignments.find_or_create_by!(customer_event_profile: cust_profile)
      return
    end

    if cust_profile
      cust_profile.credential_assignments << cred_profile.credential_assignments
      cred_profile.destroy
    else
      customer.update!(customer_event_profile: cred_profile)
      cred_profile.credential_assignments.find_or_create_by!(credentiable: obj)
    end
  end
end
