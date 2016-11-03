class EventbriteImporter < ActiveJob::Base
  def perform(order, event_id) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    order = JSON.parse(order).symbolize_keys
    event = Event.find(event_id)
    company = Company.find_or_create_by!(name: "Eventbrite")
    agreement = CompanyEventAgreement.find_or_create_by!(event: event, company: company)
    barcodes = order[:attendees].map { |attendee| attendee["barcodes"].map { |b| b["barcode"] } }.flatten

    event.tickets.where(code: barcodes).destroy_all && return unless order[:status].eql?("placed")

    ticket_types = event.company_ticket_types.where(company_event_agreement: agreement)

    order[:attendees].each do |attendee|
      attendee["barcodes"].each do |barcode|
        ctt = ticket_types.find_or_create_by!(company_code: attendee["ticket_class_id"], name: attendee["ticket_class_name"]) # rubocop:disable Metrics/LineLength
        profile = attendee["profile"]

        ticket = ctt.tickets.find_or_create_by!(code: barcode["barcode"], event: event)
        ticket.update!(purchaser_first_name: profile["first_name"], purchaser_last_name: profile["last_name"], purchaser_email: profile["email"]) # rubocop:disable Metrics/LineLength
      end
    end
  end
end
