class Profile::Checker
  def self.for_transaction(atts)
    gtag = Gtag.find_by(tag_uid: atts[:customer_tag_uid], event_id: atts[:event_id])
    tag_profile = gtag&.assigned_profile&.id
    trans_profile = atts[:profile_id]
    fail "Profile Fraud detected" if trans_profile.present? && tag_profile != trans_profile
    return tag_profile if tag_profile
    profile = Profile.create!(event_id: atts[:event_id])
    profile.credential_assignments.find_or_create_by!(credentiable: gtag, aasm_state: :assigned)
    profile.id
  end

  def self.for_credentiable(obj, customer)
    o_profile = obj.assigned_profile
    c_profile = customer.profile
    profile = c_profile || o_profile || customer.create_profile!(event: obj.event)

    fail "Credentiable Fraud detected" if o_profile&.customer
    o_profile&.destroy if c_profile && o_profile
    customer.update!(profile: profile)
    profile.credential_assignments.find_or_create_by(credentiable: obj, aasm_state: :assigned)
  end
end
