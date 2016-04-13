class Jobs::Base < ActiveJob::Base
  SEARCH_ATTS = %w( event_id device_uid device_db_index device_created_at )

  def self.write(atts)
    klass = "#{ atts[:transaction_category] }_transaction".classify.constantize
    obj_atts = extract_attributes(klass, atts)
    search_atts = atts.slice(*SEARCH_ATTS)
    obj = klass.find_by(search_atts)
    return obj if obj
    obj = klass.create(obj_atts)
    profile = new.assign_profile(obj, obj_atts)
    atts[:transaction_id] = obj.id
    atts[:customer_event_profile_id] = profile.id
    workers = descendants.select { |worker| worker::SUBSCRIPTIONS.include? atts[:transaction_type] }
    workers.each { |worker|  worker.perform_later(atts) }
    obj
  end

  def self.extract_attributes(klass, atts)
    atts.slice(*klass.column_names.map(&:to_sym))
  end

  def assign_profile(transaction, atts)
    gtag = transaction.event.gtags.find_by(tag_uid: atts[:customer_tag_uid])
    tag_profile = gtag&.assigned_customer_event_profile
    trans_profile = transaction.customer_event_profile

    if atts[:customer_event_profile_id].present? && tag_profile != trans_profile
      fail "Mismatch between customer_event_profile id '#{trans_profile&.id.inspect}' and Gtag
            uid '#{atts[:customer_tag_uid]}' with assigned profile id '#{tag_profile&.id.inspect}'"
    end

    transaction.update(customer_event_profile: tag_profile) && (return tag_profile) if tag_profile
    transaction.create_customer_event_profile!(event_id: atts[:event_id])
  end

  def self.inherited(klass)
    @descendants ||= []
    @descendants += klass.to_s.split("::").last.eql?("Base") ? klass.descendants : [klass]
  end

  def self.descendants
    @descendants || []
  end
end
