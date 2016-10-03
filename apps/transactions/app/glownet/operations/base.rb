class Operations::Base < ActiveJob::Base
  # TODO: I feel dirty doing this. Fuck me.
  OLD_SEARCH_ATTS = %w( event_id device_uid device_db_index device_created_at gtag_counter gtag_activations).freeze
  NEW_SEARCH_ATTS = %w( event_id device_uid device_db_index device_created_at_fixed gtag_counter gtag_activations).freeze

  def perform(atts)
    atts = preformat_atts(atts)
    klass = Transaction.class_for_type(atts[:transaction_category])

    obj = klass.find_by(atts.slice(*NEW_SEARCH_ATTS))
    obj ||= klass.find_by(atts.slice(*OLD_SEARCH_ATTS))
    return obj if obj

    if atts[:customer_tag_uid].present?
      gtag = Gtag.find_or_create_by!(tag_uid: atts[:customer_tag_uid], event_id: atts[:event_id], activation_counter: atts[:activation_counter])
      profile_id = Profile::Checker.for_transaction(gtag, atts[:profile_id], atts[:event_id])
      atts[:profile_id] = profile_id
    end

    obj_atts = column_attributes(klass, atts)
    obj = klass.create!(obj_atts)

    return unless atts[:status_code].to_i.zero?

    atts[:transaction_id] = obj.id
    execute_operations(atts)
  end

  def portal_write(atts) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    atts.symbolize_keys!
    event = Event.find(atts[:event_id])
    station = event.portal_station
    profile = Profile.find(atts[:profile_id])
    gtag = profile.active_gtag_assignment&.credentiable
    klass = Transaction.class_for_type(atts[:transaction_category])

    final_atts = {
      transaction_origin: Transaction::ORIGINS[:portal],
      gtag_counter: profile.all_transaction_counters.last.to_i,
      counter: profile.all_online_counters.last.to_i + 1,
      station_id: station.id,
      status_code: 0,
      status_message: "OK",
      device_uid: "portal",
      device_db_index: klass.where(event: event, station_id: station.id).count + 1,
      device_created_at: Time.zone.now.strftime("%Y-%m-%d %T.%L"),
      device_created_at_fixed: Time.zone.now.strftime("%Y-%m-%d %T.%L"),
      activation_counter: gtag&.activation_counter,
      customer_tag_uid: gtag&.tag_uid,
    }.merge(atts)

    klass.create!(column_attributes(klass, final_atts))
    execute_operations(final_atts)
  end

  def execute_operations(atts)
    # TODO: this shouldn't go here. remove when class loading is not an issue
    Operations::Credential::TicketChecker.inspect
    Operations::Credential::GtagChecker.inspect
    Operations::Credential::GtagRecycler.inspect
    Operations::Credit::BalanceUpdater.inspect
    Operations::Order::CredentialAssigner.inspect
    Operations::Order::OrderRedeemer.inspect

    children = self.class.descendants
    children.each { |klass| klass.perform_later(atts) if klass::TRIGGERS.include? atts[:transaction_type] }
  end

  def column_attributes(klass, atts)
    atts.slice(*klass.column_names.map(&:to_sym))
  end

  def preformat_atts(atts)
    atts[:customer_tag_uid] = atts[:customer_tag_uid].to_s.upcase if atts.key?(:customer_tag_uid)
    atts[:catalogable_type] = atts[:catalogable_type].to_s.camelcase if atts.key?(:catalogable_type)
    atts[:profile_id] ||= atts[:customer_event_profile_id]
    atts[:profile_id] ||= Ticket.find_by(event_id: atts[:event_id], code: atts[:ticket_code])&.assigned_profile&.id
    atts[:refundable_credits] ||= atts[:credits_refundable]
    atts[:device_created_at_fixed] = atts[:device_created_at]
    atts.delete(:station_id) if atts[:station_id].to_i.zero?
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
