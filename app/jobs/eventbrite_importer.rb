class EventbriteImporter < ActiveJob::Base
  def perform(order, event_id) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    order = JSON.parse(order).symbolize_keys

    begin
      company = Company.find_or_create_by(name: "Eventbrite - #{order[:event_id]}", event_id: event_id)
    rescue ActiveRecord::RecordNotUnique
      retry
    end

    barcodes = order[:attendees].map { |attendee| attendee["barcodes"].map { |b| b["barcode"] } }.flatten

    Ticket.where(code: barcodes, event_id: event_id).update_all(banned: true) && return unless order[:status].eql?("placed")

    order[:attendees].each do |guest|
      guest["barcodes"].each do |barcode|
        profile = guest["profile"]
        begin
          ctt = TicketType.find_or_initialize_by(company: company, company_code: guest["ticket_class_id"], event_id: event_id)
          ctt.update(name: guest["ticket_class_name"])
        rescue ActiveRecord::RecordNotUnique
          retry
        end
        begin
          ticket = Ticket.find_or_initialize_by(code: barcode["barcode"], ticket_type: ctt, event_id: event_id)
          ticket.update(created_at: barcode["created"])
        rescue ActiveRecord::RecordNotUnique
          retry
        end
        ticket.update!(purchaser_first_name: profile["first_name"], purchaser_last_name: profile["last_name"], purchaser_email: profile["email"])
      end
    end
  end
end
