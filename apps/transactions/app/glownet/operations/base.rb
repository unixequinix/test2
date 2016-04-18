class Operations::Base < ActiveJob::Base
  SEARCH_ATTS = %w( event_id device_uid device_db_index )

  def self.write(atts)
    klass = "#{ atts[:transaction_category] }_transaction".classify.constantize
    obj_atts = column_attributes(klass, atts)
    obj = klass.find_by(atts.slice(*SEARCH_ATTS))
    return obj if obj
    profile_id = Profile::Checker.for_transaction(obj_atts)
    parse_attributes!(atts, obj_atts, customer_event_profile_id: profile_id)
    obj = klass.create(obj_atts)
    Gtag.find_or_create_by!(tag_uid: atts[:customer_tag_uid], event_id: atts[:event_id])
    atts.merge!(transaction_id: obj.id, customer_event_profile_id: profile_id)
    descendants.each { |d| d.perform_later(atts) if d::TRIGGERS.include? atts[:transaction_type] }
    obj
  end

  def self.column_attributes(klass, atts)
    atts.slice(*klass.column_names.map(&:to_sym))
  end

  def self.parse_attributes!(atts, obj_atts, extra_atts = {})
    obj_atts[:device_created_at] = Time.zone.parse(atts[:device_created_at])
    sale_items = atts[:sale_items_attributes]
    obj_atts[:sale_items_attributes] = sale_items if sale_items
    obj_atts.merge!(extra_atts)
  end

  def self.inherited(klass)
    @descendants ||= []
    @descendants += klass.to_s.split("::").last.eql?("Base") ? klass.descendants : [klass]
  end

  def self.descendants
    @descendants || []
  end
end
