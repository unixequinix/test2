class Jobs::Credential::ProfileChecker < Jobs::Credential::Base
  SUBSCRIPTIONS = %w( all )

  def perform(atts)
    ActiveRecord::Base.transaction do
      t = CredentialTransaction.find(atts[:transaction_id])
      gtag = t.event.gtags.where(tag_uid: atts[:customer_tag_uid]).first
      profile = gtag&.assigned_customer_event_profile
      verify_customer_event_profile(atts, profile.id, t.customer_event_profile_id)
      t.update(customer_event_profile: profile)
      assign_profile(t, atts)
    end
  end

  def verify_customer_event_profile(atts, tag_profile_id, transaction_profile_id)
    id_present = atts[:customer_event_profile_id].present?
    return unless id_present && tag_profile_id != transaction_profile_id
    fail "Mismatch between customer_event_profile id '#{transaction_profile_id.inspect}' and Gtag
          uid '#{atts[:customer_tag_uid]}' with assigned profile id '#{tag_profile_id.inspect}'"
  end
end
