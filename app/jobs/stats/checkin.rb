class Stats::Checkin < Stats::Base
  include StatsHelper

  TRIGGERS = %w[ticket_checkin gtag_checkin].freeze

  def perform(transaction_id)
    t = CredentialTransaction.find(transaction_id)
    credential = t.ticket
    credential = t.gtag if t.action.eql?("gtag_checkin")

    atts = t.action.include?("checkin") ? { action: "checkin", name: t.action.gsub("_checkin", "") } : { action: "ticket_validation" }

    atts.merge!(extract_credential_atts(credential))
    atts.merge!(extract_ticket_type_info(credential.ticket_type))
    atts.merge!(extract_catalog_item_info(credential.ticket_type&.catalog_item))

    create_stat(extract_atts(t, atts))
  end
end
