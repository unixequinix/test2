class Jobs::Credential::ProfileChecker < Jobs::Credential::Base
  SUBSCRIPTIONS = %w( all )

  def perform(_atts)
    ActiveRecord::Base.transaction do
      t = CredentialTransaction.find(atts[:transaction_id]).includes(:event)
      event = t.event
      if atts[:customer_event_profile_id].blank?
        # if blank , check tag_uid is associated to profile, if true
        profile = event.gtags
                       .where(tag_uid: atts[:customer_tag_uid])
                       .first&.assigned_customer_event_profile
        if profile
          transaction.update customer_event_profile: profile
        else
          assign_profile(t, atts)
        end
      else
        profile = event.gtags
                       .where(tag_uid: atts[:customer_tag_uid])
                       .first&.assigned_customer_event_profile
        if t.customer_event_profile == profile
          perfecto
        else
          fail
        end
      end
    end
  end
end
