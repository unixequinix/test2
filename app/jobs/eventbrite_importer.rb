class EventbriteImporter < ActiveJob::Base
  def perform(order, event_id) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    order = JSON.parse(order).symbolize_keys
    event = Event.find(event_id)
    company = event.companies.find_by(name: "Eventbrite")
    barcodes = order[:attendees].map { |attendee| attendee["barcodes"].map { |b| b["barcode"] } }.flatten

    event.tickets.where(code: barcodes).update_all(banned: true) && return unless order[:status].eql?("placed")

    order[:attendees].each do |guest|
      guest["barcodes"].each do |barcode|
        profile = guest["profile"]
        begin
          ctt = event.ticket_types.find_or_create_by!(company: company, company_code: guest["ticket_class_id"], name: guest["ticket_class_name"])
          ticket = event.tickets.find_or_create_by!(code: barcode["barcode"], ticket_type: ctt, event: event)
        rescue ActiveRecord::RecordNotUnique
          retry
        end
        ticket.update!(purchaser_first_name: profile["first_name"], purchaser_last_name: profile["last_name"], purchaser_email: profile["email"])
      end
    end
  end
end
