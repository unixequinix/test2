class Profile::Checker
  # rubocop:disable Metrics/MethodLength, Metrics/CyclomaticComplexity
  def self.for_transaction(gtag, tr_profile_id, event_id)
    tg_profile = gtag.assigned_profile&.id
    tr_profile = Profile.find_by_id(tr_profile_id)

    if tr_profile.present? && tg_profile.present? && tg_profile != tr_profile_id
      message = "Profile fraud - Transaction: #{tr_profile_id.inspect}, Gtag: #{tg_profile.inspect}"
      raise message if tr_profile.active_gtag_assignment.present?

      gtag.assigned_gtag_credential.unassign!
      tr_profile.credential_assignments.find_or_create_by!(credentiable: gtag, aasm_state: :assigned)

      Transaction::TYPES.each do |type|
        klass = Transaction.class_for_type(type)
        klass.where(profile_id: tg_profile).update_all(profile_id: tr_profile_id)
      end

      tr_profile.transactions.credit.last.try(:recalculate_profile_balance)
      return tr_profile_id
    end

    return tr_profile_id if tr_profile
    return tg_profile if tg_profile

    profile = Profile.create!(event_id: event_id)
    profile.credential_assignments.find_or_create_by!(credentiable: gtag, aasm_state: :assigned)
    profile.id
  end

  # TODO: when o_profile and c_profile are present, merge them.
  def self.for_credentiable(obj, customer)
    o_profile = obj.assigned_profile
    return if o_profile&.customer

    c_profile = customer.profile
    profile = o_profile || c_profile || customer.create_profile!(event: obj.event)
    c_profile&.destroy if c_profile && o_profile
    customer.update!(profile: profile)
    profile.credential_assignments.find_or_create_by!(credentiable: obj, aasm_state: :assigned)
  end
end
