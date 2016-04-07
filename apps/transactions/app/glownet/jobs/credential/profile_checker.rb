class Jobs::Credential::ProfileChecker < Jobs::Credential::Base
  SUBSCRIPTIONS = %w( all )

  def perform(_atts)
    ActiveRecord::Base.transaction do
      # if id sent, check that tag_uid it matches one gtag of the profile

      # if nil , check tag_uid is associated to profile, if true
      # assign profile_id to transactions
      # else
      # create profile and assign
    end
  end
end

class Jobs::Credential::ProfileChecker < Jobs::Credential::Base
  SUBSCRIPTIONS = %w( all )

  def perform(_atts)
    ActiveRecord::Base.transaction do
      t = CredentialTransaction.find(atts[:transaction_id]).includes(:event)
      event = t.event
      if atts[:customer_event_profile_id].blank?
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
          fail "Mismatch between customer_event_profile #{t.customer_event_profile.id} and Gtag uid #{atts[:customer_tag_uid]} with profile id #{profile.id}"
        end
      end
    end
  end
end
