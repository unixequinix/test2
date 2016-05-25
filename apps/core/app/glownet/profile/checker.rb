class Profile::Checker
  def self.for_transaction(gtag, tr_profile, event_id)
    tg_profile = gtag.assigned_profile&.id
    message = "Profile error - Transaction: #{tr_profile.inspect}, Gtag: #{tg_profile.inspect}"

    raise message if tr_profile.present? && tg_profile.present? && tg_profile != tr_profile
    return tg_profile if tg_profile
    return tr_profile if tr_profile

    profile = Profile.create!(event_id: event_id)
    profile.credential_assignments.find_or_create_by!(credentiable: gtag, aasm_state: :assigned)
    profile.id
  end

  # TODO: when o_profile and c_profile are present, merge them.
  def self.for_credentiable(obj, customer)
    o_profile = obj.assigned_profile
    raise "Credentiable Fraud detected" if o_profile&.customer

    c_profile = customer.profile
    profile = o_profile || c_profile || customer.create_profile!(event: obj.event)
    c_profile&.destroy if c_profile && o_profile
    customer.update!(profile: profile)
    profile.credential_assignments.find_or_create_by!(credentiable: obj, aasm_state: :assigned)
  end
end
