class Operations::Base < ActiveJob::Base
  SEARCH_ATTS = %w( event_id device_uid device_db_index device_created_at gtag_counter ).freeze

  def perform(atts) # rubocop:disable Metrics/AbcSize
    atts[:profile_id] ||= atts[:customer_event_profile_id]
    atts.delete(:station_id) if atts[:station_id].to_i.zero?
    atts.delete(:sale_items_attributes) if atts[:sale_items_attributes].blank?
    klass = "#{atts[:transaction_category]}_transaction".classify.constantize

    obj = klass.find_by(atts.slice(*SEARCH_ATTS))
    return obj if obj
    return klass.create!(column_attributes(klass, atts)) unless atts[:status_code].to_i.zero?

    gtag = Gtag.find_or_create_by!(tag_uid: atts[:customer_tag_uid], event_id: atts[:event_id])
    profile_id = Profile::Checker.for_transaction(gtag, atts[:profile_id], atts[:event_id])
    atts[:profile_id] = profile_id

    obj_atts = column_attributes(klass, atts)
    obj = klass.create!(obj_atts)

    atts[:transaction_id] = obj.id
    execute_operations(atts)
  end

  def portal_write(atts) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    event = Event.find(atts[:event_id])
    station = event.portal_station
    profile = Profile.find(atts[:profile_id])
    klass = "#{atts[:transaction_category]}_transaction".classify.constantize
    counter = klass.where(event: event,
                          profile_id: atts[:profile_id],
                          transaction_origin: "customer_portal").count + 1

    final_atts = {
      transaction_origin: "customer_portal",
      counter: counter,
      station_id: station.id,
      status_code: 0,
      status_message: "OK",
      device_uid: "portal",
      device_db_index: klass.where(event: event, station_id: station.id).count + 1,
      device_created_at: Time.zone.now.strftime("%Y-%m-%d %T.%L"),
      customer_tag_uid: profile.active_gtag_assignment&.credentiable&.tag_uid
    }.merge(atts.symbolize_keys)

    klass.create!(column_attributes(klass, final_atts))
    execute_operations(final_atts)
  end

  def execute_operations(atts)
    children = self.class.descendants
    children.each { |d| d.perform_later(atts) if d::TRIGGERS.include? atts[:transaction_type] }
  end

  def column_attributes(klass, atts)
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
