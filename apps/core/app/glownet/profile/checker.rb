class Profile::Checker
  def self.assign_profile(obj, atts)
    gtag = obj.event.gtags.find_by(tag_uid: atts[:customer_tag_uid])
    tag_profile = gtag&.assigned_customer_event_profile
    trans_profile = obj.customer_event_profile

    if atts[:customer_event_profile_id].present? && tag_profile != trans_profile
      fail "Mismatch between customer_event_profile id '#{trans_profile&.id.inspect}' and Gtag
            uid '#{atts[:customer_tag_uid]}' with assigned profile id '#{tag_profile&.id.inspect}'"
    end

    obj.update(customer_event_profile: tag_profile) && (return tag_profile) if tag_profile
    obj.create_customer_event_profile!(event_id: atts[:event_id])
  end
end
