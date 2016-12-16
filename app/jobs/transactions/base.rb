class Transactions::Base < ActiveJob::Base
  SEARCH_ATTS = %w(event_id device_uid device_db_index device_created_at_fixed gtag_counter activation_counter).freeze

  def perform(atts) # rubocop:disable Metrics/MethodLength
    atts = preformat_atts(atts)
    klass = Transaction.class_for_type(atts[:type])
    atts[:type] = klass.to_s

    obj = klass.find_by(atts.slice(*SEARCH_ATTS))
    return obj if obj

    if atts[:customer_tag_uid].present?
      gtag_atts = { tag_uid: atts[:customer_tag_uid], event_id: atts[:event_id], activation_counter: atts[:activation_counter] } # rubocop:disable Metrics/LineLength
      gtag = Gtag.find_or_create_by!(gtag_atts)

      prev_activation = Gtag.find_by("tag_uid = ? AND activation_counter < ?", gtag.tag_uid, gtag.activation_counter)
      gtag.update!(format: prev_activation.format, loyalty: prev_activation.loyalty) if prev_activation
      atts[:gtag_id] = gtag.id
    end

    obj_atts = column_attributes(klass, atts)
    obj = klass.create!(obj_atts)

    return unless atts[:status_code].to_i.zero?

    atts[:transaction_id] = obj.id
    execute_operations(atts)
  end

  def portal_write(atts) # rubocop:disable Metrics/MethodLength
    atts.symbolize_keys!
    event = Event.find(atts[:event_id])
    klass = atts[:type].constantize
    customer = event.customers.find(atts[:customer_id])
    station = event.portal_station
    final_atts = {
      transaction_origin: Transaction::ORIGINS[:portal],
      counter: customer.transactions.maximum(:counter).to_i + 1,
      station_id: station.id,
      status_code: 0,
      status_message: "OK",
      device_db_index: klass.where(event: event, station_id: station.id).count + 1,
      device_created_at: Time.zone.now.strftime("%Y-%m-%d %T.%L"),
      device_created_at_fixed: Time.zone.now.strftime("%Y-%m-%d %T.%L")
    }.merge(atts)

    klass.create!(column_attributes(klass, final_atts))
    execute_operations(final_atts)
  end

  def execute_operations(atts)
    children = self.class.descendants
    children.each { |klass| klass.perform_later(atts) if klass::TRIGGERS.include? atts[:action] }
  end

  def column_attributes(klass, atts)
    atts.slice(*klass.column_names.map(&:to_sym))
  end

  def preformat_atts(atts)
    atts[:transaction_origin] = Transaction::ORIGINS[:device]
    atts[:station_id] = Station.find_by(event_id: atts[:event_id], station_event_id: atts[:station_id])&.id
    atts[:customer_tag_uid] = atts[:customer_tag_uid].to_s.upcase if atts.key?(:customer_tag_uid)
    atts[:order_item_counter] = atts[:order_item_id] if atts.key?(:order_item_id)
    atts[:device_created_at_fixed] = atts[:device_created_at]
    atts.delete(:sale_items_attributes) if atts[:sale_items_attributes].blank?
    atts
  end

  def self.inherited(klass)
    @descendants ||= []
    @descendants += klass.to_s.split("::").last.eql?("Base") ? klass.descendants : [klass]
  end

  def self.descendants
    @descendants || []
  end
end
