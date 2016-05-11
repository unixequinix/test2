class Operations::Base < ActiveJob::Base
  SEARCH_ATTS = %w( event_id device_uid device_db_index device_created_at ).freeze

  def perform(atts) # rubocop:disable Metrics/AbcSize
    atts[:profile_id] ||= atts[:customer_event_profile_id]
    klass = "#{atts[:transaction_category]}_transaction".classify.constantize

    obj = klass.find_by(atts.slice(*SEARCH_ATTS))
    return obj if obj
    return portal_write(atts) unless atts[:status_code].to_i.zero?

    Gtag.find_or_create_by!(tag_uid: atts[:customer_tag_uid], event_id: atts[:event_id])
    profile_id = Profile::Checker.for_transaction(atts)

    obj_atts = column_attributes(klass, atts, :sale_items_attributes)
    obj_atts[:profile_id] = profile_id
    obj = klass.create!(obj_atts)

    atts[:transaction_id] = obj.id
    atts[:profile_id] = profile_id
    children = self.class.descendants
    children.each { |d| d.perform_later(atts) if d::TRIGGERS.include? atts[:transaction_type] }
    obj
  end

  def portal_write(atts)
    klass = "#{atts[:transaction_category]}_transaction".classify.constantize
    klass.create!(column_attributes(klass, atts))
  end

  def column_attributes(klass, atts, extras = [])
    columns = [extras].flatten + klass.column_names.map(&:to_sym)
    atts.slice(*columns)
  end

  def self.inherited(klass)
    @descendants ||= []
    @descendants += klass.to_s.split("::").last.eql?("Base") ? klass.descendants : [klass]
  end

  def self.descendants
    @descendants || []
  end
end
