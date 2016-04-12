class Jobs::Base < ActiveJob::Base
  SEARCH_ATTS = %w( event_id device_uid device_db_index device_created_at )

  def self.write(atts)
    klass = "#{ atts[:transaction_category] }_transaction".classify.constantize
    obj_atts = extract_attributes(klass, atts)
    obj = klass.find_by(atts.slice(*SEARCH_ATTS))
    return obj if obj
    obj = klass.create(obj_atts)
    profile_id = Profile::Checker.for_transaction(obj_atts)
    obj.update!(customer_event_profile_id: profile_id)
    atts.merge!(transaction_id: obj.id, customer_event_profile_id: profile_id)
    descendants.each { |d| d.perform_later(atts) if d::TRIGGERS.include? atts[:transaction_type] }
    obj
  end

  def self.extract_attributes(klass, atts)
    atts.slice(*klass.column_names.map(&:to_sym))
  end

  def self.inherited(klass)
    @descendants ||= []
    @descendants += klass.to_s.split("::").last.eql?("Base") ? klass.descendants : [klass]
  end

  def self.descendants
    @descendants || []
  end
end
