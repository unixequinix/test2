module Ticketing
  class EventbriteImporter < ApplicationJob
    def perform(order, integration)
      order = JSON.parse(order).symbolize_keys

      barcodes = order[:attendees].map { |attendee| attendee["barcodes"].map { |b| b["barcode"] } }.flatten

      integration.event.tickets.where(code: barcodes).update_all(banned: true) && return unless order[:status].eql?("placed")

      order[:attendees].each do |guest|
        guest["barcodes"].each do |barcode|
          profile = guest["profile"]
          begin
            ctt = integration.ticket_types.find_or_initialize_by(company_code: guest["ticket_class_id"], event_id: integration.event_id)
            ctt.update!(company: "Eventbrite", name: guest["ticket_class_name"], money_base: order[:costs]["base_price"]["major_value"].to_f)
          rescue ActiveRecord::RecordNotUnique
            retry
          end
          begin
            ticket = ctt.tickets.find_or_initialize_by(code: barcode["barcode"], event_id: integration.event_id)
            ticket.update!(created_at: barcode["created"], purchaser_first_name: profile["first_name"], purchaser_last_name: profile["last_name"], purchaser_email: profile["email"])
          rescue ActiveRecord::RecordNotUnique
            retry
          end
        end
      end
    end
  end
end
