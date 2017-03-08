class EventbriteImporter < ActiveJob::Base
  def perform(order, event_id) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    order = JSON.parse(order).symbolize_keys
    event = Event.find(event_id)
    company = event.companies.find_by(name: "Eventbrite")
    barcodes = order[:attendees].map { |attendee| attendee["barcodes"].map { |b| b["barcode"] } }.flatten

    event.tickets.where(code: barcodes).update_all(banned: true) && return unless order[:status].eql?("placed")

    order[:attendees].each do |attendee|
      attendee["barcodes"].each do |barcode|
        profile = attendee["profile"]

        begin
          ctt = TicketType.find_or_create_by(company: company, company_code: attendee["ticket_class_id"], event: event, name: attendee["ticket_class_name"]) # rubocop:disable Metrics/LineLength
        rescue ActiveRecord::RecordNotUnique
          retry
        end

        begin
          ticket = Ticket.find_or_initialize_by(code: barcode["barcode"], company_ticket_type: ctt, event: event)
          ticket.update!(purchaser_first_name: profile["first_name"], purchaser_last_name: profile["last_name"], purchaser_email: profile["email"])
        rescue ActiveRecord::RecordNotUnique
          retry
        end
      end
    end
  end
end
